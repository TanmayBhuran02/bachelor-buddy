/// Core Riverpod providers for database, theme, and app state.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/db/app_database.dart';
import 'core/events/domain_event.dart';
import 'features/actions/action_intent.dart';
import 'features/actions/local_intent_parser.dart';

// ─── Database ──────────────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ─── Event Bus ─────────────────────────────────────────────────────────────

final eventBusProvider = Provider<EventBus>((ref) {
  final bus = EventBus();
  ref.onDispose(() => bus.dispose());
  return bus;
});

// ─── Action Pipeline ───────────────────────────────────────────────────────

final actionRegistryProvider = Provider<ActionRegistry>((ref) {
  final registry = ActionRegistry();
  // Handlers will be registered here as they are implemented
  return registry;
});

final intentParserProvider = Provider<IntentParser>((ref) {
  return LocalIntentParser();
});

// ─── Theme ─────────────────────────────────────────────────────────────────

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark; // Default to dark; loaded from DB on startup
});

// ─── Onboarding ────────────────────────────────────────────────────────────

final showOnboardingProvider = StateProvider<bool>((ref) {
  return false; // Set on app startup based on first_run flag
});
