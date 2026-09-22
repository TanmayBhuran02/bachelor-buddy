/// Riverpod providers for Water Tracker.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bachelor_buddy/providers.dart';
import 'package:bachelor_buddy/features/water/data/water_repository.dart';
import 'package:bachelor_buddy/core/db/app_database.dart';

final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final eventBus = ref.watch(eventBusProvider);
  return WaterRepository(db, eventBus);
});

/// Watch water settings
final waterSettingsProvider = StreamProvider<WaterSetting>((ref) {
  final repo = ref.watch(waterRepositoryProvider);
  return repo.watchSettings();
});

/// Watch today's water status (intake, goal, logs)
final todayWaterStatusProvider = StreamProvider<TodayWaterStatus>((ref) {
  final repo = ref.watch(waterRepositoryProvider);
  return repo.watchTodayStatus();
});

/// Watch 7-day history
final weeklyWaterHistoryProvider =
    StreamProvider<List<DailyWaterSummary>>((ref) {
  final repo = ref.watch(waterRepositoryProvider);
  return repo.watchWeeklyHistory();
});
