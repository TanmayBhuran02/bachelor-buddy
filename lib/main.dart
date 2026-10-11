/// Application entry point.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/db/app_database.dart';
import 'core/events/domain_event.dart';
import 'core/notifications/notification_scheduler.dart';
import 'core/widgets_sync/widget_callbacks.dart';
import 'core/widgets_sync/widget_sync_service.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create shared database instance
  final db = AppDatabase();
  final eventBus = EventBus();

  // Initialize home_widget & callbacks safely
  try {
    await WidgetSyncService.initialize();
    await registerWidgetCallbacks();
    await WidgetSyncService.syncAll(db);
  } catch (e) {
    debugPrint('Widget initialization error: $e');
  }

  // Automatically sync widgets whenever in-app domain events fire
  WidgetSyncService.listenToEvents(db, eventBus);

  // Initialize notifications and schedule reminders safely
  try {
    await NotificationScheduler.initialize(db, eventBus);
  } catch (e) {
    debugPrint('Notification initialization error: $e');
  }

  // Load user preferences from DB (default to light mode)
  ThemeMode initialTheme = ThemeMode.light;
  bool isBiometricLockEnabled = false;

  try {
    final themeSetting = await (db.select(db.appSettings)
          ..where((s) => s.key.equals('theme_mode')))
        .getSingleOrNull();
    if (themeSetting?.value == 'dark') {
      initialTheme = ThemeMode.dark;
    }

    final biometricSetting = await (db.select(db.appSettings)
          ..where((s) => s.key.equals('biometric_lock_enabled')))
        .getSingleOrNull();
    isBiometricLockEnabled = biometricSetting?.value == 'true';
  } catch (e) {
    debugPrint('Settings load error: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themeModeProvider.overrideWith((ref) => initialTheme),
        biometricLockEnabledProvider.overrideWith((ref) => isBiometricLockEnabled),
        isAuthenticatedProvider.overrideWith((ref) => !isBiometricLockEnabled),
      ],
      child: const BachelorBuddyApp(),
    ),
  );
}
