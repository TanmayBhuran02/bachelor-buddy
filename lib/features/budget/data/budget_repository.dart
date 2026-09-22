/// Repository for Budget Planner and Recurring Expenses.
library;

import 'package:drift/drift.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:uuid/uuid.dart';

import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/features/expenses/data/expense_repository.dart';

const _uuid = Uuid();

class CategoryBudgetStatus {
  final Category category;
  final int spentPaise;
  final int? limitPaise;

  CategoryBudgetStatus({
    required this.category,
    required this.spentPaise,
    this.limitPaise,
  });

  double get percentage =>
      (limitPaise != null && limitPaise! > 0) ? (spentPaise / limitPaise!) : 0.0;
}

class MonthBudgetOverview {
  final int limitPaise;
  final int spentPaise;
  final int remainingDays;
  final List<CategoryBudgetStatus> categoryStatuses;

  MonthBudgetOverview({
    required this.limitPaise,
    required this.spentPaise,
    required this.remainingDays,
    required this.categoryStatuses,
  });

  int get remainingPaise => limitPaise - spentPaise;
  double get percentage => limitPaise > 0 ? (spentPaise / limitPaise) : 0.0;

  int get safeToSpendPerDayPaise {
    if (remainingDays <= 0 || remainingPaise <= 0) return 0;
    return remainingPaise ~/ remainingDays;
  }
}

class BudgetRepository {
  final AppDatabase _db;
  final ExpenseRepository _expenseRepo;

  BudgetRepository(this._db, this._expenseRepo);

  /// Watch budget overview for a month ('YYYY-MM')
  Stream<MonthBudgetOverview> watchBudgetOverview(String monthStr) {
    final budgetsQuery = _db.select(_db.budgets)
      ..where((b) => b.month.equals(monthStr));

    final txQuery = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])..where(_db.transactions.date.like('$monthStr%') &
        _db.transactions.type.equals('expense'));

    return budgetsQuery.watch().switchMap((budgets) {
      return txQuery.watch().asyncMap((txRows) async {
        final allCategories = await (_db.select(_db.categories)
              ..where((c) => c.kind.equals('expense')))
            .get();

        int overallLimit = 0;
        final categoryLimits = <String, int>{};

        for (final b in budgets) {
          if (b.categoryId == null) {
            overallLimit = b.limitPaise;
          } else {
            categoryLimits[b.categoryId!] = b.limitPaise;
          }
        }

        int totalSpent = 0;
        final categorySpends = <String, int>{};

        for (final row in txRows) {
          final tx = row.readTable(_db.transactions);
          totalSpent += tx.amountPaise;
          categorySpends[tx.categoryId] =
              (categorySpends[tx.categoryId] ?? 0) + tx.amountPaise;
        }

        final statuses = allCategories.map((cat) {
          return CategoryBudgetStatus(
            category: cat,
            spentPaise: categorySpends[cat.id] ?? 0,
            limitPaise: categoryLimits[cat.id],
          );
        }).toList();

        // Calculate remaining days in month
        final now = DateTime.now();
        final parts = monthStr.split('-');
        final year = int.tryParse(parts[0]) ?? now.year;
        final month = int.tryParse(parts[1]) ?? now.month;

        final lastDay = DateTime(year, month + 1, 0).day;
        int remainingDays = 1;
        if (now.year == year && now.month == month) {
          remainingDays = (lastDay - now.day + 1).clamp(1, 31);
        } else if (DateTime(year, month).isAfter(now)) {
          remainingDays = lastDay;
        } else {
          remainingDays = 1; // Past month
        }

        return MonthBudgetOverview(
          limitPaise: overallLimit,
          spentPaise: totalSpent,
          remainingDays: remainingDays,
          categoryStatuses: statuses,
        );
      });
    });
  }

  /// Set or update budget limit
  Future<void> setBudget({
    required String month,
    String? categoryId,
    required int limitPaise,
  }) async {
    final existing = await (_db.select(_db.budgets)
          ..where((b) =>
              b.month.equals(month) &
              (categoryId != null
                  ? b.categoryId.equals(categoryId)
                  : b.categoryId.isNull())))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.budgets)..where((b) => b.id.equals(existing.id)))
          .write(BudgetsCompanion(limitPaise: Value(limitPaise)));
    } else {
      await _db.into(_db.budgets).insert(
            BudgetsCompanion.insert(
              id: _uuid.v4(),
              month: month,
              categoryId: Value(categoryId),
              limitPaise: limitPaise,
            ),
          );
    }
  }

  /// Watch recurring expenses
  Stream<List<RecurringExpense>> watchRecurringExpenses() {
    final query = _db.select(_db.recurringExpenses)
      ..orderBy([(r) => OrderingTerm.asc(r.dayOfMonth)]);
    return query.watch();
  }

  /// Add recurring expense
  Future<String> addRecurringExpense({
    required String title,
    required int amountPaise,
    required String categoryId,
    required int dayOfMonth,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.recurringExpenses).insert(
          RecurringExpensesCompanion.insert(
            id: id,
            title: title,
            amountPaise: amountPaise,
            categoryId: categoryId,
            dayOfMonth: dayOfMonth,
            isActive: const Value(true),
          ),
        );
    return id;
  }

  /// Delete recurring expense
  Future<void> deleteRecurringExpense(String id) async {
    await (_db.delete(_db.recurringExpenses)..where((r) => r.id.equals(id)))
        .go();
  }

  /// Process recurring expenses for current month
  Future<void> processRecurringExpenses(String currentMonth) async {
    final now = DateTime.now();
    final recurrings = await (_db.select(_db.recurringExpenses)
          ..where((r) => r.isActive.equals(true)))
        .get();

    for (final rec in recurrings) {
      if (rec.lastGeneratedMonth != currentMonth && now.day >= rec.dayOfMonth) {
        final dateStr =
            '$currentMonth-${rec.dayOfMonth.toString().padLeft(2, '0')}';

        await _expenseRepo.addTransaction(
          amountPaise: rec.amountPaise,
          type: 'expense',
          categoryId: rec.categoryId,
          note: rec.title,
          date: dateStr,
          source: 'recurring',
          sourceRefId: rec.id,
        );

        await (_db.update(_db.recurringExpenses)
              ..where((r) => r.id.equals(rec.id)))
            .write(
          RecurringExpensesCompanion(
            lastGeneratedMonth: Value(currentMonth),
          ),
        );
      }
    }
  }
}
