/// Riverpod providers for the Expense Tracker.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bachelor_buddy/providers.dart';
import 'package:bachelor_buddy/features/expenses/data/expense_repository.dart';
import 'package:bachelor_buddy/core/db/app_database.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final eventBus = ref.watch(eventBusProvider);
  return ExpenseRepository(db, eventBus);
});

/// Current month string in 'YYYY-MM' format
final selectedMonthProvider = StateProvider<String>((ref) {
  return DateFormat('yyyy-MM').format(DateTime.now());
});

/// Optional category filter for expense list
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Search filter
final expenseSearchQueryProvider = StateProvider<String>((ref) => '');

/// Stream of transactions matching active month and filters
final transactionsStreamProvider =
    StreamProvider<List<TransactionWithCategory>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  final categoryId = ref.watch(selectedCategoryFilterProvider);
  final searchQuery = ref.watch(expenseSearchQueryProvider);

  return repo.watchTransactions(
    monthPrefix: month,
    categoryId: categoryId,
    searchQuery: searchQuery,
  );
});

/// Stream of monthly totals (income, expense, balance)
final monthlyTotalsStreamProvider = StreamProvider<MonthlyTotals>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  return repo.watchMonthlyTotals(month);
});

/// Stream of categories
final categoriesStreamProvider =
    StreamProvider.family<List<Category>, String?>((ref, kind) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.watchCategories(kind: kind);
});
