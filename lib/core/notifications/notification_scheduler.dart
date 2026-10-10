/// Notification Scheduler service that bridges Database, EventBus,
/// NotificationService, and incoming native transaction broadcasts.
library;

import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/core/diagnostics/logger.dart';
import 'package:bachelor_buddy/core/events/domain_event.dart';
import 'package:bachelor_buddy/core/money.dart';
import 'package:bachelor_buddy/core/notifications/notification_preferences.dart';
import 'package:bachelor_buddy/core/notifications/notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:bachelor_buddy/features/expenses/data/txn_parser.dart';

class NotificationScheduler {
  static const MethodChannel _txnChannel =
      MethodChannel('com.bachelorbuddy/txn_listener');

  static bool _listenersAttached = false;
  static final Set<String> _alertedBudgetThresholds = {};

  /// Initialize all notification reminders and event listeners
  static Future<void> initialize(AppDatabase db, EventBus eventBus) async {
    final notifService = NotificationService();
    await notifService.initialize();
    await notifService.requestPermissions();

    final prefs = await NotificationPreferences.load(db);

    // Initial sync
    await syncAllReminders(db, prefs);
    await NotificationPreferences.syncNativeMonitoredPackages(
      prefs.notifyTxnListener,
      prefs.enabledTxnPackages,
    );

    if (!_listenersAttached) {
      _listenersAttached = true;
      _listenToDomainEvents(db, eventBus);
      _listenToNativeTxnBroadcasts(db, eventBus);
    }

    AppLogger.info('NotificationScheduler initialized', context: 'Notification');
  }

  /// Sync all scheduled reminders based on user preferences and current DB state
  static Future<void> syncAllReminders(
    AppDatabase db,
    NotificationPreferences prefs,
  ) async {
    final notifService = NotificationService();

    // 1. Water Reminders
    if (prefs.notifyWater) {
      final waterSettings = await (db.select(db.waterSettings)
            ..where((s) => s.id.equals(1)))
          .getSingleOrNull();

      if (waterSettings != null && waterSettings.remindersEnabled) {
        final startParts = waterSettings.dayStart.split(':');
        final endParts = waterSettings.dayEnd.split(':');
        final startH = int.tryParse(startParts[0]) ?? 8;
        final startM =
            startParts.length > 1 ? int.tryParse(startParts[1]) ?? 0 : 0;
        final endH = int.tryParse(endParts[0]) ?? 22;
        final endM =
            endParts.length > 1 ? int.tryParse(endParts[1]) ?? 0 : 0;

        await notifService.scheduleWaterReminders(
          intervalMinutes: waterSettings.reminderIntervalMin,
          startHour: startH,
          startMinute: startM,
          endHour: endH,
          endMinute: endM,
        );
      } else {
        await notifService.cancelWaterReminders();
      }
    } else {
      await notifService.cancelWaterReminders();
    }

    // 2. Tiffin Reminders
    if (prefs.notifyTiffin) {
      final activePlans = await (db.select(db.tiffinPlans)
            ..where((p) => p.isActive.equals(true)))
          .get();

      for (final plan in activePlans) {
        final parts = plan.reminderTime.split(':');
        final hour = int.tryParse(parts[0]) ??
            (plan.mealType == 'lunch'
                ? 12
                : plan.mealType == 'dinner'
                    ? 20
                    : 8);
        final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

        await notifService.scheduleTiffinReminder(
          id: NotificationService.hashId(plan.id, 20000),
          providerName: plan.providerName,
          mealType: plan.mealType,
          hour: hour,
          minute: minute,
        );
      }
    } else {
      // Cancel tiffin reminders
      final allPlans = await db.select(db.tiffinPlans).get();
      for (final plan in allPlans) {
        await notifService.cancel(NotificationService.hashId(plan.id, 20000));
      }
    }

    // 3. To-Do Reminders
    if (prefs.notifyTodo) {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final pendingTodos = await (db.select(db.todos)
            ..where((t) =>
                t.isDone.equals(false) &
                t.dueAt.isNotNull() &
                t.dueAt.isBiggerThanValue(nowMs)))
          .get();

      for (final todo in pendingTodos) {
        if (todo.dueAt != null) {
          await notifService.scheduleTodoReminder(
            id: NotificationService.hashId(todo.id, 40000),
            title: todo.title,
            dueAt: DateTime.fromMillisecondsSinceEpoch(todo.dueAt!),
          );
        }
      }
    }
  }

  /// Listen to Domain Events
  static void _listenToDomainEvents(AppDatabase db, EventBus eventBus) {
    final notifService = NotificationService();

    eventBus.stream.listen((event) async {
      final prefs = await NotificationPreferences.load(db);

      // Hydration check
      if (event is WaterLogged && prefs.notifyWater) {
        if (event.dailyTotalMl >= event.goalMl && event.goalMl > 0) {
          // Goal reached, cancel remaining water alerts for today
          await notifService.cancelWaterReminders();
        }
      }

      // Todo Created / Updated
      if (event is TodoCreated && prefs.notifyTodo) {
        final todo = await (db.select(db.todos)
              ..where((t) => t.id.equals(event.todoId)))
            .getSingleOrNull();
        if (todo != null && todo.dueAt != null && !todo.isDone) {
          await notifService.scheduleTodoReminder(
            id: NotificationService.hashId(todo.id, 40000),
            title: todo.title,
            dueAt: DateTime.fromMillisecondsSinceEpoch(todo.dueAt!),
          );
        }
      }

      // Todo Completed
      if (event is TodoCompleted) {
        await notifService.cancel(NotificationService.hashId(event.todoId, 40000));
      }

      // Budget threshold check
      if ((event is TransactionCreated ||
              event is ExpenseAdded ||
              event is TransactionUpdated ||
              event is ExpenseUpdated) &&
          prefs.notifyBudget) {
        await _checkBudgetThresholds(db, notifService);
      }
    });
  }

  /// Check monthly budget limits and fire alerts if threshold is crossed
  static Future<void> _checkBudgetThresholds(
    AppDatabase db,
    NotificationService notifService,
  ) async {
    final now = DateTime.now();
    final currentMonth = DateFormat('yyyy-MM').format(now);

    final overallBudget = await (db.select(db.budgets)
          ..where((b) =>
              b.month.equals(currentMonth) & b.categoryId.isNull()))
        .getSingleOrNull();

    if (overallBudget == null || overallBudget.limitPaise <= 0) return;

    // Calculate total expenses for month
    final startOfMonth =
        DateTime(now.year, now.month, 1).toUtc().millisecondsSinceEpoch;
    final endOfMonth =
        DateTime(now.year, now.month + 1, 0, 23, 59, 59)
            .toUtc()
            .millisecondsSinceEpoch;

    final txns = await (db.select(db.transactions)
          ..where((t) =>
              t.type.equals('expense') &
              t.createdAt.isBetweenValues(startOfMonth, endOfMonth)))
        .get();

    final totalSpentPaise =
        txns.fold<int>(0, (sum, t) => sum + t.amountPaise);
    final limit = overallBudget.limitPaise;
    final ratio = totalSpentPaise / limit;

    final key100 = '$currentMonth-100';
    final key90 = '$currentMonth-90';
    final key75 = '$currentMonth-75';

    if (ratio >= 1.0 && !_alertedBudgetThresholds.contains(key100)) {
      _alertedBudgetThresholds.add(key100);
      await notifService.showBudgetAlert(
        id: 9100,
        title: '🚨 Monthly Budget Exceeded!',
        body:
            'You have spent ${Money.format(totalSpentPaise, showDecimal: false)} of your ${Money.format(limit, showDecimal: false)} budget.',
      );
    } else if (ratio >= 0.9 &&
        !_alertedBudgetThresholds.contains(key90) &&
        ratio < 1.0) {
      _alertedBudgetThresholds.add(key90);
      await notifService.showBudgetAlert(
        id: 9090,
        title: '⚠️ 90% Budget Reached',
        body:
            'Spent ${Money.format(totalSpentPaise, showDecimal: false)}. Only ${Money.format(limit - totalSpentPaise, showDecimal: false)} remaining this month.',
      );
    } else if (ratio >= 0.75 &&
        !_alertedBudgetThresholds.contains(key75) &&
        ratio < 0.9) {
      _alertedBudgetThresholds.add(key75);
      await notifService.showBudgetAlert(
        id: 9075,
        title: '⚠️ 75% Budget Warning',
        body:
            'You have spent 75% of your monthly budget (${Money.format(totalSpentPaise, showDecimal: false)} / ${Money.format(limit, showDecimal: false)}).',
      );
    }
  }

  /// Listen to native transaction broadcasts and automatically record into database
  static void _listenToNativeTxnBroadcasts(AppDatabase db, EventBus eventBus) {
    _txnChannel.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationReceived') {
        try {
          final args = call.arguments as Map<dynamic, dynamic>;
          final packageName = args['packageName']?.toString() ?? '';
          final text = args['text']?.toString() ?? '';

          final prefs = await NotificationPreferences.load(db);
          if (!prefs.notifyTxnListener) {
            return;
          }

          // Check if package is enabled
          if (!prefs.enabledTxnPackages.contains(packageName)) {
            return;
          }

          AppLogger.info(
            'Received notification from monitored app: $packageName',
            context: 'TxnListener',
          );

          // Parse transaction
          final parsed = TxnParser.parse(
            text: text,
            packageName: packageName,
          );

          if (parsed == null || parsed.amountPaise <= 0) {
            AppLogger.info(
              'Ignored: text from $packageName did not match any transaction format',
              context: 'TxnListener',
            );
            return;
          }

          AppLogger.info(
            'Parsed ${parsed.type}: ${Money.format(parsed.amountPaise, showDecimal: false)} for "${parsed.merchantOrParty}" via ${parsed.appSource}',
            context: 'TxnListener',
          );

          // Find appropriate category for kind
          final categories = await (db.select(db.categories)
                ..where((c) => c.kind.equals(parsed.type)))
              .get();

          String categoryId;
          if (categories.isNotEmpty) {
            final match = categories.firstWhere(
              (c) => c.name.toLowerCase().contains('other'),
              orElse: () => categories.first,
            );
            categoryId = match.id;
          } else {
            final anyCat =
                await (db.select(db.categories)..limit(1)).getSingleOrNull();
            categoryId = anyCat?.id ?? 'default';
          }

          final txId = const Uuid().v4();
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

          // Auto-insert into database
          await db.into(db.transactions).insert(
                TransactionsCompanion.insert(
                  id: txId,
                  amountPaise: parsed.amountPaise,
                  type: parsed.type,
                  categoryId: categoryId,
                  note: Value('${parsed.merchantOrParty} (${parsed.appSource})'),
                  date: todayStr,
                  source: const Value('auto_detected'),
                  createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
                ),
              );

          AppLogger.info(
            'Inserted transaction $txId into database under category $categoryId',
            context: 'TxnListener',
          );

          // Fire event to update widgets, budget totals, and lists
          eventBus.fire(TransactionCreated(
            transactionId: txId,
            amountPaise: parsed.amountPaise,
            type: parsed.type,
            categoryId: categoryId,
            date: todayStr,
            source: 'auto_detected',
          ));

          final notifService = NotificationService();
          final id = NotificationService.hashId(
            '${parsed.amountPaise}-${DateTime.now().millisecondsSinceEpoch}',
            80000,
          );

          final actionText =
              parsed.type == 'expense' ? 'Expense' : 'Income';

          await notifService.showTxnDetectedNotification(
            id: id,
            title:
                '⚡ Auto-Added $actionText: ${Money.format(parsed.amountPaise, showDecimal: false)} (${parsed.appSource})',
            body:
                '${parsed.merchantOrParty} • Recorded in expenses. Tap to view.',
            payload: 'txn_recorded:$txId',
          );

          AppLogger.info(
            'Auto-recorded transaction $txId: ${parsed.amountPaise} paise from ${parsed.appSource}',
            context: 'TxnListener',
          );
        } catch (e, stack) {
          AppLogger.error(
            'Error handling incoming txn notification: $e\n$stack',
            context: 'TxnListener',
          );
        }
      }
    });
  }
}
