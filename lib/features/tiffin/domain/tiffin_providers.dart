/// Riverpod providers for Tiffin Tracker.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bachelor_buddy/providers.dart';
import 'package:bachelor_buddy/features/expenses/domain/expense_providers.dart';
import 'package:bachelor_buddy/features/tiffin/data/tiffin_repository.dart';
import 'package:bachelor_buddy/core/db/app_database.dart';

final tiffinRepositoryProvider = Provider<TiffinRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final eventBus = ref.watch(eventBusProvider);
  return TiffinRepository(db, expenseRepo, eventBus);
});

/// Selected date for viewing / updating tiffin daily status
final tiffinSelectedDateProvider = StateProvider<String>((ref) {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
});

/// Watch active plans
final activeTiffinPlansProvider = StreamProvider<List<TiffinPlan>>((ref) {
  final repo = ref.watch(tiffinRepositoryProvider);
  return repo.watchActivePlans();
});

/// Watch plans for selected date
final tiffinPlansForSelectedDateProvider =
    StreamProvider<List<TiffinPlanWithLog>>((ref) {
  final repo = ref.watch(tiffinRepositoryProvider);
  final selectedDate = ref.watch(tiffinSelectedDateProvider);
  return repo.watchPlansForDate(selectedDate);
});

/// Watch monthly summary for tiffin
final tiffinMonthlySummaryProvider =
    StreamProvider<TiffinMonthlySummary>((ref) {
  final repo = ref.watch(tiffinRepositoryProvider);
  final selectedDate = ref.watch(tiffinSelectedDateProvider);
  final monthPrefix = selectedDate.substring(0, 7); // 'YYYY-MM'
  return repo.watchMonthlySummary(monthPrefix);
});

/// Watch all logs for month (for calendar badges)
final tiffinLogsForMonthProvider =
    StreamProvider<List<TiffinLog>>((ref) {
  final repo = ref.watch(tiffinRepositoryProvider);
  final selectedDate = ref.watch(tiffinSelectedDateProvider);
  final monthPrefix = selectedDate.substring(0, 7);
  return repo.watchLogsForMonth(monthPrefix);
});
