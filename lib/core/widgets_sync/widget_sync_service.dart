/// Widget sync service: pushes JSON snapshots to home_widget storage
/// and triggers native widget updates.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:bachelor_buddy/core/diagnostics/logger.dart';

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
    await HomeWidget.setAppGroupId(_appGroupId);
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

  /// Refresh all widgets (e.g. after DB migration or midnight rollover)
  static Future<void> refreshAll(Map<WidgetKey, Map<String, dynamic>> snapshots) async {
    for (final entry in snapshots.entries) {
      await refresh(entry.key, entry.value);
    }
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
