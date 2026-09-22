/// Expense repository handling CRUD and queries on transactions and categories.
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/core/events/domain_event.dart';

const _uuid = Uuid();

class TransactionWithCategory {
  final Transaction transaction;
  final Category category;

  TransactionWithCategory({
    required this.transaction,
    required this.category,
  });
}

class MonthlyTotals {
  final int totalIncomePaise;
  final int totalExpensePaise;

  MonthlyTotals({
    required this.totalIncomePaise,
    required this.totalExpensePaise,
  });

  int get balancePaise => totalIncomePaise - totalExpensePaise;
}

class ExpenseRepository {
  final AppDatabase _db;
  final EventBus _eventBus;

  ExpenseRepository(this._db, this._eventBus);

  /// Watch transactions for a given month (YYYY-MM), sorted newest first.
  Stream<List<TransactionWithCategory>> watchTransactions({
    required String monthPrefix,
    String? categoryId,
    String? searchQuery,
  }) {
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ]);

    query.where(_db.transactions.date.like('$monthPrefix%'));

    if (categoryId != null && categoryId.isNotEmpty) {
      query.where(_db.transactions.categoryId.equals(categoryId));
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where(
        _db.transactions.note.like('%$searchQuery%') |
            _db.categories.name.like('%$searchQuery%'),
      );
    }

    query.orderBy([
      OrderingTerm.desc(_db.transactions.date),
      OrderingTerm.desc(_db.transactions.createdAt),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          transaction: row.readTable(_db.transactions),
          category: row.readTable(_db.categories),
        );
      }).toList();
    });
  }

  /// Watch monthly totals (income and expense in paise)
  Stream<MonthlyTotals> watchMonthlyTotals(String monthPrefix) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.date.like('$monthPrefix%'));

    return query.watch().map((rows) {
      int income = 0;
      int expense = 0;
      for (final row in rows) {
        if (row.type == 'income') {
          income += row.amountPaise;
        } else {
          expense += row.amountPaise;
        }
      }
      return MonthlyTotals(
        totalIncomePaise: income,
        totalExpensePaise: expense,
      );
    });
  }

  /// Watch all categories
  Stream<List<Category>> watchCategories({String? kind}) {
    final query = _db.select(_db.categories);
    if (kind != null) {
      query.where((c) => c.kind.equals(kind));
    }
    query.orderBy([(c) => OrderingTerm.asc(c.name)]);
    return query.watch();
  }

  /// Get transaction by ID
  Future<Transaction?> getTransaction(String id) async {
    return (_db.select(_db.transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Insert a transaction
  Future<String> addTransaction({
    required int amountPaise,
    required String type, // 'expense' | 'income'
    required String categoryId,
    required String note,
    required String date, // YYYY-MM-DD
    String source = 'manual',
    String? sourceRefId,
    bool isShared = false,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            id: id,
            amountPaise: amountPaise,
            type: type,
            categoryId: categoryId,
            note: Value(note),
            date: date,
            source: Value(source),
            sourceRefId: Value(sourceRefId),
            isShared: Value(isShared),
            createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
          ),
        );

    _eventBus.fire(TransactionCreated(
      transactionId: id,
      amountPaise: amountPaise,
      type: type,
      categoryId: categoryId,
      date: date,
      source: source,
    ));

    return id;
  }

  /// Update an existing transaction
  Future<void> updateTransaction({
    required String id,
    required int amountPaise,
    required String type,
    required String categoryId,
    required String note,
    required String date,
    bool isShared = false,
  }) async {
    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        amountPaise: Value(amountPaise),
        type: Value(type),
        categoryId: Value(categoryId),
        note: Value(note),
        date: Value(date),
        isShared: Value(isShared),
      ),
    );

    _eventBus.fire(TransactionUpdated(
      transactionId: id,
      amountPaise: amountPaise,
      type: type,
      categoryId: categoryId,
      date: date,
    ));
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String id) async {
    final existing = await getTransaction(id);
    if (existing == null) return;

    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();

    _eventBus.fire(TransactionDeleted(
      transactionId: id,
      amountPaise: existing.amountPaise,
      type: existing.type,
      categoryId: existing.categoryId,
      date: existing.date,
    ));
  }

  /// Add custom category
  Future<String> addCategory({
    required String name,
    required String iconKey,
    required String colorHex,
    required String kind,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            name: name,
            iconKey: Value(iconKey),
            colorHex: Value(colorHex),
            kind: kind,
            isDefault: const Value(false),
          ),
        );
    return id;
  }
}
