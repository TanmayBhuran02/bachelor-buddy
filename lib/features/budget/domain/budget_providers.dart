/// Riverpod providers for Budget Planner.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bachelor_buddy/providers.dart';
import 'package:bachelor_buddy/features/expenses/domain/expense_providers.dart';
import 'package:bachelor_buddy/features/budget/data/budget_repository.dart';
import 'package:bachelor_buddy/core/db/app_database.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  return BudgetRepository(db, expenseRepo);
});

/// Watch budget overview for the selected month
final budgetOverviewProvider = StreamProvider<MonthBudgetOverview>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  final month = ref.watch(selectedMonthProvider);
  return repo.watchBudgetOverview(month);
});

/// Watch recurring expenses
final recurringExpensesProvider =
    StreamProvider<List<RecurringExpense>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.watchRecurringExpenses();
});
