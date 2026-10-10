/// Manages notification preferences and permissions across sections.
library;

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/core/diagnostics/logger.dart';

class SupportedApp {
  final String packageName;
  final String displayName;

  const SupportedApp({
    required this.packageName,
    required this.displayName,
  });
}

const List<SupportedApp> kSupportedUpiApps = [
  SupportedApp(
    packageName: 'com.google.android.apps.nbu.paisa.user',
    displayName: 'Google Pay',
  ),
  SupportedApp(
    packageName: 'com.phonepe.app',
    displayName: 'PhonePe',
  ),
  SupportedApp(
    packageName: 'net.one97.paytm',
    displayName: 'Paytm',
  ),
  SupportedApp(
    packageName: 'money.super.app',
    displayName: 'super.money',
  ),
  SupportedApp(
    packageName: 'com.whatsapp',
    displayName: 'WhatsApp Pay',
  ),
];

class NotificationPreferences {
  final bool notifyWater;
  final bool notifyTiffin;
  final bool notifyTodo;
  final bool notifyBudget;
  final bool notifyTxnListener;
  final Set<String> enabledTxnPackages;

  const NotificationPreferences({
    this.notifyWater = true,
    this.notifyTiffin = true,
    this.notifyTodo = true,
    this.notifyBudget = true,
    this.notifyTxnListener = false,
    this.enabledTxnPackages = const {
      'com.google.android.apps.nbu.paisa.user',
      'com.phonepe.app',
      'net.one97.paytm',
      'money.super.app',
      'com.whatsapp',
    },
  });

  NotificationPreferences copyWith({
    bool? notifyWater,
    bool? notifyTiffin,
    bool? notifyTodo,
    bool? notifyBudget,
    bool? notifyTxnListener,
    Set<String>? enabledTxnPackages,
  }) {
    return NotificationPreferences(
      notifyWater: notifyWater ?? this.notifyWater,
      notifyTiffin: notifyTiffin ?? this.notifyTiffin,
      notifyTodo: notifyTodo ?? this.notifyTodo,
      notifyBudget: notifyBudget ?? this.notifyBudget,
      notifyTxnListener: notifyTxnListener ?? this.notifyTxnListener,
      enabledTxnPackages: enabledTxnPackages ?? this.enabledTxnPackages,
    );
  }

  static const _platform = MethodChannel('com.bachelorbuddy/txn_listener');

  /// Check if Android Notification Listener permission is granted
  static Future<bool> isNotificationListenerGranted() async {
    try {
      final granted =
          await _platform.invokeMethod<bool>('isNotificationListenerGranted');
      return granted ?? false;
    } catch (e) {
      AppLogger.warn('Failed to check notification listener permission: $e');
      return false;
    }
  }

  /// Deep link to Android Notification Listener Access settings page
  static Future<void> openNotificationListenerSettings() async {
    try {
      await _platform.invokeMethod('openNotificationListenerSettings');
    } catch (e) {
      AppLogger.error('Failed to open notification settings: $e');
    }
  }

  /// Load preferences from database
  static Future<NotificationPreferences> load(AppDatabase db) async {
    final settings = await db.select(db.appSettings).get();
    final map = {for (final s in settings) s.key: s.value};

    final water = map['notify_water_enabled'] != 'false';
    final tiffin = map['notify_tiffin_enabled'] != 'false';
    final todo = map['notify_todo_enabled'] != 'false';
    final budget = map['notify_budget_enabled'] != 'false';
    final txn = map['notify_txn_listener_enabled'] == 'true';

    Set<String> packages = {
      'com.google.android.apps.nbu.paisa.user',
      'com.phonepe.app',
      'net.one97.paytm',
      'money.super.app',
      'com.whatsapp',
    };

    if (map['notify_txn_packages'] != null) {
      try {
        final list = jsonDecode(map['notify_txn_packages']!) as List<dynamic>;
        packages = list.map((e) => e.toString()).toSet();
      } catch (_) {}
    }

    return NotificationPreferences(
      notifyWater: water,
      notifyTiffin: tiffin,
      notifyTodo: todo,
      notifyBudget: budget,
      notifyTxnListener: txn,
      enabledTxnPackages: packages,
    );
  }

  /// Save preferences to database
  static Future<void> save(
    AppDatabase db,
    NotificationPreferences prefs,
  ) async {
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'notify_water_enabled',
            value: prefs.notifyWater ? 'true' : 'false',
          ),
        );
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'notify_tiffin_enabled',
            value: prefs.notifyTiffin ? 'true' : 'false',
          ),
        );
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'notify_todo_enabled',
            value: prefs.notifyTodo ? 'true' : 'false',
          ),
        );
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'notify_budget_enabled',
            value: prefs.notifyBudget ? 'true' : 'false',
          ),
        );
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'notify_txn_listener_enabled',
            value: prefs.notifyTxnListener ? 'true' : 'false',
          ),
        );
    await db.into(db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'notify_txn_packages',
            value: jsonEncode(prefs.enabledTxnPackages.toList()),
          ),
        );
  }
}
