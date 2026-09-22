/// Background callback entry point for interactive widget actions.
/// This runs in its own isolate — it must NOT depend on Flutter UI or Riverpod.
/// It opens the DB directly, mutates, and refreshes the widget.
library;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/core/diagnostics/logger.dart';
import 'package:bachelor_buddy/core/widgets_sync/widget_sync_service.dart';

const _uuid = Uuid();

/// Top-level entry point for widget background callbacks.
/// Must be annotated for AOT compilation.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;

  AppLogger.info('Widget callback received: $uri', context: 'WidgetCallback');

  try {
    final action = uri.host;
    final params = uri.queryParameters;

    final db = AppDatabase();

    switch (action) {
      case 'water_add_glass':
        await _handleWaterAddGlass(db, params);
      case 'tiffin_mark_received':
        await _handleTiffinMarkReceived(db, params);
      case 'tiffin_skip':
        await _handleTiffinSkip(db, params);
      case 'quick_expense':
        await _handleQuickExpense(db, params);
      case 'todo_toggle':
        await _handleTodoToggle(db, params);
      default:
        AppLogger.warn('Unknown widget action: $action', context: 'WidgetCallback');
    }
  } catch (e, stack) {
    AppLogger.error(
      'Widget callback error: $e\n$stack',
      context: 'WidgetCallback',
    );
  }
}

Future<void> _handleWaterAddGlass(AppDatabase db, Map<String, String> params) async {
  final amount = int.tryParse(params['amount'] ?? '200') ?? 200;
  final now = DateTime.now().millisecondsSinceEpoch;

  await db.into(db.waterLogs).insert(
        WaterLogsCompanion.insert(
          id: _uuid.v4(),
          amountMl: amount,
          loggedAt: now,
        ),
      );

  await WidgetSyncService.syncWater(db);
  AppLogger.info('Water glass added from widget: +$amount ml', context: 'WidgetCallback');
}

Future<void> _handleTiffinMarkReceived(AppDatabase db, Map<String, String> params) async {
  final planId = params['planId'];
  final date = params['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  if (planId == null || planId.isEmpty) return;

  final plan = await (db.select(db.tiffinPlans)..where((p) => p.id.equals(planId))).getSingleOrNull();
  if (plan == null) return;

  final existingLog = await (db.select(db.tiffinLogs)
        ..where((l) => l.planId.equals(planId) & l.date.equals(date)))
      .getSingleOrNull();

  String logId;
  String? txId;

  if (existingLog != null) {
    logId = existingLog.id;
    txId = existingLog.transactionId;
    await (db.update(db.tiffinLogs)..where((l) => l.id.equals(logId))).write(
      const TiffinLogsCompanion(status: Value('received')),
    );
  } else {
    logId = _uuid.v4();
    await db.into(db.tiffinLogs).insert(
          TiffinLogsCompanion.insert(
            id: logId,
            planId: planId,
            date: date,
            status: const Value('received'),
          ),
        );
  }

  // Auto-create expense if none linked
  if (txId == null) {
    final categories = await db.select(db.categories).get();
    final foodCat = categories.firstWhere(
      (c) => c.name.toLowerCase() == 'tiffin' || c.name.toLowerCase() == 'food',
      orElse: () => categories.first,
    );

    final newTxId = _uuid.v4();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            id: newTxId,
            amountPaise: plan.pricePerTiffinPaise,
            type: 'expense',
            categoryId: foodCat.id,
            note: Value('Tiffin - ${plan.mealType} (${plan.providerName})'),
            date: date,
            source: const Value('tiffin'),
            sourceRefId: Value(logId),
            createdAt: nowMs,
          ),
        );

    await (db.update(db.tiffinLogs)..where((l) => l.id.equals(logId))).write(
      TiffinLogsCompanion(transactionId: Value(newTxId)),
    );
  }

  await WidgetSyncService.syncTiffin(db);
  await WidgetSyncService.syncBudget(db);
  AppLogger.info('Tiffin marked received from widget: plan=$planId', context: 'WidgetCallback');
}

Future<void> _handleTiffinSkip(AppDatabase db, Map<String, String> params) async {
  final planId = params['planId'];
  final date = params['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  if (planId == null || planId.isEmpty) return;

  final existingLog = await (db.select(db.tiffinLogs)
        ..where((l) => l.planId.equals(planId) & l.date.equals(date)))
      .getSingleOrNull();

  if (existingLog != null) {
    if (existingLog.transactionId != null) {
      await (db.delete(db.transactions)..where((t) => t.id.equals(existingLog.transactionId!))).go();
    }
    await (db.update(db.tiffinLogs)..where((l) => l.id.equals(existingLog.id))).write(
      const TiffinLogsCompanion(
        status: Value('skipped'),
        transactionId: Value(null),
      ),
    );
  } else {
    await db.into(db.tiffinLogs).insert(
          TiffinLogsCompanion.insert(
            id: _uuid.v4(),
            planId: planId,
            date: date,
            status: const Value('skipped'),
          ),
        );
  }

  await WidgetSyncService.syncTiffin(db);
  AppLogger.info('Tiffin marked skipped from widget: plan=$planId', context: 'WidgetCallback');
}

Future<void> _handleQuickExpense(AppDatabase db, Map<String, String> params) async {
  final amountPaise = int.tryParse(params['amount'] ?? '2000') ?? 2000;
  final note = params['note'] ?? 'Quick Expense';
  final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final nowMs = DateTime.now().millisecondsSinceEpoch;

  final categories = await db.select(db.categories).get();
  final foodCat = categories.firstWhere(
    (c) => c.name.toLowerCase() == 'food' || c.name.toLowerCase() == 'chai',
    orElse: () => categories.first,
  );

  await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: _uuid.v4(),
          amountPaise: amountPaise,
          type: 'expense',
          categoryId: foodCat.id,
          note: Value(note),
          date: todayStr,
          source: const Value('widget'),
          createdAt: nowMs,
        ),
      );

  await WidgetSyncService.syncBudget(db);
  AppLogger.info('Quick expense logged from widget: $note ₹${amountPaise ~/ 100}', context: 'WidgetCallback');
}

Future<void> _handleTodoToggle(AppDatabase db, Map<String, String> params) async {
  final todoId = params['todoId'];
  if (todoId == null || todoId.isEmpty) return;

  final todo = await (db.select(db.todos)..where((t) => t.id.equals(todoId))).getSingleOrNull();
  if (todo != null) {
    await (db.update(db.todos)..where((t) => t.id.equals(todoId))).write(
      TodosCompanion(isDone: Value(!todo.isDone)),
    );
    await WidgetSyncService.syncTodos(db);
  }
}

/// Register the background callback with home_widget
Future<void> registerWidgetCallbacks() async {
  if (kIsWeb) return;
  await HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
}
