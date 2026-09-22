/// Repository for Water Tracker managing intake logs, hydration goals,
/// reminder settings, and streak metrics.
library;

import 'package:drift/drift.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:uuid/uuid.dart';

import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/core/events/domain_event.dart';

const _uuid = Uuid();

class TodayWaterStatus {
  final int intakeMl;
  final int goalMl;
  final int glassMl;
  final List<WaterLog> logs;

  TodayWaterStatus({
    required this.intakeMl,
    required this.goalMl,
    required this.glassMl,
    required this.logs,
  });

  double get progress => goalMl > 0 ? (intakeMl / goalMl).clamp(0.0, 1.0) : 0.0;
  int get glassesDrank => glassMl > 0 ? (intakeMl / glassMl).floor() : 0;
  int get totalGlasses => glassMl > 0 ? (goalMl / glassMl).ceil() : 0;
}

class DailyWaterSummary {
  final DateTime date;
  final int totalMl;
  final int goalMl;

  DailyWaterSummary({
    required this.date,
    required this.totalMl,
    required this.goalMl,
  });

  bool get reachedGoal => totalMl >= goalMl;
}

class WaterRepository {
  final AppDatabase _db;
  final EventBus _eventBus;

  WaterRepository(this._db, this._eventBus);

  /// Watch settings (row id = 1)
  Stream<WaterSetting> watchSettings() {
    return (_db.select(_db.waterSettings)..where((s) => s.id.equals(1)))
        .watchSingle();
  }

  /// Watch today's water status (intake, goal, logs)
  Stream<TodayWaterStatus> watchTodayStatus() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day)
        .toUtc()
        .millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999)
        .toUtc()
        .millisecondsSinceEpoch;

    final logsQuery = _db.select(_db.waterLogs)
      ..where((l) => l.loggedAt.isBetweenValues(startOfDay, endOfDay))
      ..orderBy([(l) => OrderingTerm.desc(l.loggedAt)]);

    return watchSettings().switchMap((settings) {
      return logsQuery.watch().map((logs) {
        final totalMl = logs.fold<int>(0, (acc, l) => acc + l.amountMl);
        return TodayWaterStatus(
          intakeMl: totalMl,
          goalMl: settings.dailyGoalMl,
          glassMl: settings.glassMl,
          logs: logs,
        );
      });
    });
  }

  /// Watch weekly daily water summaries (last 7 days)
  Stream<List<DailyWaterSummary>> watchWeeklyHistory() {
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 6))
        .toUtc()
        .millisecondsSinceEpoch;

    final logsQuery = _db.select(_db.waterLogs)
      ..where((l) => l.loggedAt.isBiggerOrEqualValue(sevenDaysAgo));

    return watchSettings().switchMap((settings) {
      return logsQuery.watch().map((logs) {
        final Map<String, int> dailyTotals = {};

        for (final log in logs) {
          final date = DateTime.fromMillisecondsSinceEpoch(log.loggedAt).toLocal();
          final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          dailyTotals[key] = (dailyTotals[key] ?? 0) + log.amountMl;
        }

        final summaries = <DailyWaterSummary>[];
        for (int i = 6; i >= 0; i--) {
          final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
          final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          final total = dailyTotals[key] ?? 0;
          summaries.add(DailyWaterSummary(
            date: day,
            totalMl: total,
            goalMl: settings.dailyGoalMl,
          ));
        }

        return summaries;
      });
    });
  }

  /// Log water intake
  Future<void> addWater(int amountMl) async {
    final id = _uuid.v4();
    final nowEpoch = DateTime.now().toUtc().millisecondsSinceEpoch;

    await _db.into(_db.waterLogs).insert(
          WaterLogsCompanion.insert(
            id: id,
            amountMl: amountMl,
            loggedAt: nowEpoch,
          ),
        );

    final settings = await (_db.select(_db.waterSettings)
          ..where((s) => s.id.equals(1)))
        .getSingle();

    // Query today's total
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day)
        .toUtc()
        .millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999)
        .toUtc()
        .millisecondsSinceEpoch;

    final todayLogs = await (_db.select(_db.waterLogs)
          ..where((l) => l.loggedAt.isBetweenValues(startOfDay, endOfDay)))
        .get();

    final todayTotal = todayLogs.fold<int>(0, (acc, l) => acc + l.amountMl);

    _eventBus.fire(WaterLogged(
      amountMl: amountMl,
      dailyTotalMl: todayTotal,
      goalMl: settings.dailyGoalMl,
    ));
  }

  /// Delete a water log entry
  Future<void> deleteWaterLog(String id) async {
    await (_db.delete(_db.waterLogs)..where((l) => l.id.equals(id))).go();
  }

  /// Update settings
  Future<void> updateSettings({
    required int dailyGoalMl,
    required int glassMl,
    required String dayStart,
    required String dayEnd,
    required int reminderIntervalMin,
    required bool remindersEnabled,
  }) async {
    await (_db.update(_db.waterSettings)..where((s) => s.id.equals(1))).write(
      WaterSettingsCompanion(
        dailyGoalMl: Value(dailyGoalMl),
        glassMl: Value(glassMl),
        dayStart: Value(dayStart),
        dayEnd: Value(dayEnd),
        reminderIntervalMin: Value(reminderIntervalMin),
        remindersEnabled: Value(remindersEnabled),
      ),
    );
  }
}
