/// Application entry point.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/db/app_database.dart';
import 'core/events/domain_event.dart';
import 'core/widgets_sync/widget_callbacks.dart';
import 'core/widgets_sync/widget_sync_service.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize home_widget
  await WidgetSyncService.initialize();

  // Register widget background callbacks
  await registerWidgetCallbacks();

  // Create shared database instance
  final db = AppDatabase();

  // Initial widget sync with real data
  await WidgetSyncService.syncAll(db);

  // Automatically sync widgets whenever in-app domain events fire
  final eventBus = EventBus();
  WidgetSyncService.listenToEvents(db, eventBus);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
      child: const BachelorBuddyApp(),
    ),
  );
}
