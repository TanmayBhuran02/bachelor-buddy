/// Widget sync service: pushes JSON snapshots to home_widget storage
/// and triggers native widget updates.
library;

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/core/diagnostics/logger.dart';
import 'package:bachelor_buddy/core/events/domain_event.dart';
import 'package:bachelor_buddy/core/money.dart';

/// Keys for different widget types
enum WidgetKey {
  tiffin('tiffin_widget'),
  todo('todo_widget'),
  water('water_widget'),
  budget('budget_widget'),
  quickExpense('quick_expense_widget');

  final String value;
  const WidgetKey(this.value);
}

class WidgetSyncService {
  static const _appGroupId = 'com.bachelorbuddy.widgets';

  /// Initialize home_widget
  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(_appGroupId);
      AppLogger.info('HomeWidget initialized', context: 'WidgetSync');
    } catch (e) {
      AppLogger.error('Failed to initialize HomeWidget: $e', context: 'WidgetSync');
    }
  }

  /// Push a JSON snapshot for a specific widget and trigger update
  static Future<void> refresh(WidgetKey key, Map<String, dynamic> data) async {
    if (kIsWeb) return;
    try {
      final jsonStr = jsonEncode(data);
      await HomeWidget.saveWidgetData<String>(key.value, jsonStr);
      await HomeWidget.updateWidget(
        androidName: _androidWidgetName(key),
      );
      AppLogger.info(
        'Widget refreshed: ${key.value}',
        context: 'WidgetSync',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to refresh widget ${key.value}: $e',
        context: 'WidgetSync',
      );
    }
  }

  /// Sync water widget from database
  static Future<void> syncWater(AppDatabase db) async {
    try {
      final settings = await (db.select(db.waterSettings)).getSingleOrNull();
      final goalMl = settings?.dailyGoalMl ?? 2500;
      final glassMl = settings?.glassMl ?? 200;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch;

      final logs = await (db.select(db.waterLogs)
            ..where((l) => l.loggedAt.isBiggerOrEqualValue(startOfDay) & l.loggedAt.isSmallerOrEqualValue(endOfDay)))
          .get();

      final totalIntake = logs.fold<int>(0, (sum, l) => sum + l.amountMl);
      final glassesDrank = glassMl > 0 ? (totalIntake / glassMl).floor() : 0;
      final totalGlasses = glassMl > 0 ? (goalMl / glassMl).ceil() : 12;

      await refresh(WidgetKey.water, {
        'intakeMl': totalIntake,
        'goalMl': goalMl,
        'glassMl': glassMl,
        'glassesDrank': glassesDrank,
        'totalGlasses': totalGlasses,
      });
    } catch (e) {
      AppLogger.error('Failed to sync water widget: $e', context: 'WidgetSync');
    }
  }

  /// Sync tiffin widget from database
  static Future<void> syncTiffin(AppDatabase db) async {
    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final activePlans = await (db.select(db.tiffinPlans)..where((p) => p.isActive.equals(true))).get();
      if (activePlans.isEmpty) {
        await refresh(WidgetKey.tiffin, {
          'meal': 'No Active Plan',
          'status': 'inactive',
          'price': '',
          'planId': '',
          'date': todayStr,
        });
        return;
      }

      // Pick current or next meal
      final plan = activePlans.first;
      final log = await (db.select(db.tiffinLogs)
            ..where((l) => l.planId.equals(plan.id) & l.date.equals(todayStr)))
          .getSingleOrNull();

      final status = log?.status ?? 'pending';

      await refresh(WidgetKey.tiffin, {
        'meal': '${plan.mealType.toUpperCase()} • ${plan.providerName}',
        'status': status,
        'price': Money.format(plan.pricePerTiffinPaise, showDecimal: false),
        'planId': plan.id,
        'date': todayStr,
      });
    } catch (e) {
      AppLogger.error('Failed to sync tiffin widget: $e', context: 'WidgetSync');
    }
  }

  /// Sync budget widget from database
  static Future<void> syncBudget(AppDatabase db) async {
    try {
      final now = DateTime.now();
      final monthPrefix = DateFormat('yyyy-MM').format(now);

      final budgetRow = await (db.select(db.budgets)..where((b) => b.month.equals(monthPrefix))).getSingleOrNull();
      final limitPaise = budgetRow?.limitPaise ?? 2500000; // Default ₹25,000

      final txRows = await (db.select(db.transactions)
            ..where((t) => t.date.like('$monthPrefix%') & t.type.equals('expense')))
          .get();

      final totalSpentPaise = txRows.fold<int>(0, (sum, t) => sum + t.amountPaise);

      final percentage = limitPaise > 0 ? ((totalSpentPaise / limitPaise) * 100).round() : 0;
      final remainingPaise = limitPaise - totalSpentPaise;

      // Calculate days left in month
      final lastDay = DateTime(now.year, now.month + 1, 0).day;
      final daysLeft = (lastDay - now.day + 1).clamp(1, 31);
      final safeToSpendPaise = remainingPaise > 0 ? (remainingPaise / daysLeft).round() : 0;

      await refresh(WidgetKey.budget, {
        'spentStr': Money.format(totalSpentPaise, showDecimal: false),
        'limitStr': Money.format(limitPaise, showDecimal: false),
        'percentage': percentage,
        'safeToSpendStr': '${Money.format(safeToSpendPaise, showDecimal: false)} / day',
      });
    } catch (e) {
      AppLogger.error('Failed to sync budget widget: $e', context: 'WidgetSync');
    }
  }

  /// Sync todos widget from database
  static Future<void> syncTodos(AppDatabase db) async {
    try {
      final pendingTodos = await (db.select(db.todos)
            ..where((t) => t.isDone.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.priority), (t) => OrderingTerm.asc(t.createdAt)])
            ..limit(6))
          .get();

      final tasksList = pendingTodos.map((t) => {'id': t.id, 'title': t.title}).toList();

      await refresh(WidgetKey.todo, {
        'tasks': tasksList,
      });
    } catch (e) {
      AppLogger.error('Failed to sync todo widget: $e', context: 'WidgetSync');
    }
  }

  /// Sync all widgets with latest DB data
  static Future<void> syncAll(AppDatabase db) async {
    await syncWater(db);
    await syncTiffin(db);
    await syncBudget(db);
    await syncTodos(db);
  }

  /// Listen to DomainEvent bus and automatically re-sync corresponding widgets
  static void listenToEvents(AppDatabase db, EventBus bus) {
    bus.stream.listen((event) {
      if (event is TransactionCreated ||
          event is TransactionUpdated ||
          event is TransactionDeleted ||
          event is ExpenseAdded ||
          event is ExpenseUpdated ||
          event is ExpenseDeleted) {
        syncBudget(db);
      } else if (event is TiffinReceived || event is TiffinSkipped) {
        syncTiffin(db);
        syncBudget(db);
      } else if (event is WaterLogged) {
        syncWater(db);
      } else if (event is TodoCreated ||
          event is TodoUpdated ||
          event is TodoCompleted) {
        syncTodos(db);
      }
    });
  }

  /// Get the Android AppWidgetProvider class name for each widget
  static String _androidWidgetName(WidgetKey key) => switch (key) {
        WidgetKey.tiffin => 'TiffinWidgetProvider',
        WidgetKey.todo => 'TodoWidgetProvider',
        WidgetKey.water => 'WaterWidgetProvider',
        WidgetKey.budget => 'BudgetWidgetProvider',
        WidgetKey.quickExpense => 'QuickExpenseWidgetProvider',
      };
}
