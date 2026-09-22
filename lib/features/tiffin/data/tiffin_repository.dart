/// Repository for Tiffin Tracker managing meal plans, daily logs,
/// and automatic expense synchronization.
library;

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/core/events/domain_event.dart';
import 'package:bachelor_buddy/features/expenses/data/expense_repository.dart';

const _uuid = Uuid();

class TiffinPlanWithLog {
  final TiffinPlan plan;
  final TiffinLog? log;

  TiffinPlanWithLog({required this.plan, this.log});
}

class TiffinMonthlySummary {
  final int totalReceived;
  final int totalSkipped;
  final int totalPending;
  final int totalBillPaise;

  TiffinMonthlySummary({
    required this.totalReceived,
    required this.totalSkipped,
    required this.totalPending,
    required this.totalBillPaise,
  });
}

class TiffinRepository {
  final AppDatabase _db;
  final ExpenseRepository _expenseRepo;
  final EventBus _eventBus;

  TiffinRepository(this._db, this._expenseRepo, this._eventBus);

  /// Watch all active tiffin plans
  Stream<List<TiffinPlan>> watchActivePlans() {
    final query = _db.select(_db.tiffinPlans)
      ..where((p) => p.isActive.equals(true));
    return query.watch();
  }

  /// Watch plans with their daily log status for a specific date (YYYY-MM-DD)
  Stream<List<TiffinPlanWithLog>> watchPlansForDate(String dateStr) {
    return watchActivePlans().asyncMap((plans) async {
      final results = <TiffinPlanWithLog>[];
      for (final plan in plans) {
        final log = await (_db.select(_db.tiffinLogs)
              ..where((l) => l.planId.equals(plan.id) & l.date.equals(dateStr)))
            .getSingleOrNull();
        results.add(TiffinPlanWithLog(plan: plan, log: log));
      }
      return results;
    });
  }

  /// Watch monthly summary for a given month prefix (YYYY-MM)
  Stream<TiffinMonthlySummary> watchMonthlySummary(String monthPrefix) {
    final query = _db.select(_db.tiffinLogs).join([
      innerJoin(
        _db.tiffinPlans,
        _db.tiffinPlans.id.equalsExp(_db.tiffinLogs.planId),
      ),
    ])..where(_db.tiffinLogs.date.like('$monthPrefix%'));

    return query.watch().map((rows) {
      int received = 0;
      int skipped = 0;
      int pending = 0;
      int totalBill = 0;

      for (final row in rows) {
        final log = row.readTable(_db.tiffinLogs);
        final plan = row.readTable(_db.tiffinPlans);

        if (log.status == 'received') {
          received++;
          final price = log.priceOverridePaise ?? plan.pricePerTiffinPaise;
          totalBill += price;
        } else if (log.status == 'skipped') {
          skipped++;
        } else {
          pending++;
        }
      }

      return TiffinMonthlySummary(
        totalReceived: received,
        totalSkipped: skipped,
        totalPending: pending,
        totalBillPaise: totalBill,
      );
    });
  }

  /// Watch all logs for a month to render monthly calendar indicators
  Stream<List<TiffinLog>> watchLogsForMonth(String monthPrefix) {
    final query = _db.select(_db.tiffinLogs)
      ..where((l) => l.date.like('$monthPrefix%'));
    return query.watch();
  }

  /// Create a new tiffin plan
  Future<String> createPlan({
    required String providerName,
    required String mealType, // breakfast|lunch|dinner
    required int pricePerTiffinPaise,
    required int activeWeekdaysMask, // 1=Mon..64=Sun (127 for all)
    required String reminderTime, // HH:mm
    required String startDate, // YYYY-MM-DD
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.tiffinPlans).insert(
          TiffinPlansCompanion.insert(
            id: id,
            providerName: providerName,
            mealType: mealType,
            pricePerTiffinPaise: pricePerTiffinPaise,
            activeWeekdaysMask: activeWeekdaysMask,
            reminderTime: Value(reminderTime),
            startDate: startDate,
            isActive: const Value(true),
          ),
        );
    return id;
  }

  /// Update an existing tiffin plan
  Future<void> updatePlan({
    required String id,
    required String providerName,
    required String mealType,
    required int pricePerTiffinPaise,
    required int activeWeekdaysMask,
    required String reminderTime,
  }) async {
    await (_db.update(_db.tiffinPlans)..where((p) => p.id.equals(id))).write(
      TiffinPlansCompanion(
        providerName: Value(providerName),
        mealType: Value(mealType),
        pricePerTiffinPaise: Value(pricePerTiffinPaise),
        activeWeekdaysMask: Value(activeWeekdaysMask),
        reminderTime: Value(reminderTime),
      ),
    );
  }

  /// Mark tiffin as received for a given date
  Future<void> markReceived({
    required String planId,
    required String date,
    int? priceOverridePaise,
  }) async {
    final plan = await (_db.select(_db.tiffinPlans)
          ..where((p) => p.id.equals(planId)))
        .getSingleOrNull();
    if (plan == null) return;

    final price = priceOverridePaise ?? plan.pricePerTiffinPaise;

    // Check if log already exists
    final existingLog = await (_db.select(_db.tiffinLogs)
          ..where((l) => l.planId.equals(planId) & l.date.equals(date)))
        .getSingleOrNull();

    String logId;
    String? txId;

    if (existingLog != null) {
      logId = existingLog.id;
      txId = existingLog.transactionId;

      // Update existing log status
      await (_db.update(_db.tiffinLogs)..where((l) => l.id.equals(logId))).write(
        TiffinLogsCompanion(
          status: const Value('received'),
          priceOverridePaise: Value(priceOverridePaise),
        ),
      );

      // If transaction already exists, update its amount
      if (txId != null) {
        final existingTx = await _expenseRepo.getTransaction(txId);
        if (existingTx != null) {
          await _expenseRepo.updateTransaction(
            id: txId,
            amountPaise: price,
            type: 'expense',
            categoryId: existingTx.categoryId,
            note: 'Tiffin - ${plan.mealType} (${plan.providerName})',
            date: date,
          );
        }
      }
    } else {
      logId = _uuid.v4();
      await _db.into(_db.tiffinLogs).insert(
            TiffinLogsCompanion.insert(
              id: logId,
              planId: planId,
              date: date,
              status: const Value('received'),
              priceOverridePaise: Value(priceOverridePaise),
            ),
          );
    }

    // If no transaction linked yet, create auto-expense
    if (txId == null) {
      // Find 'Tiffin' or 'Food' category
      final categories = await _db.select(_db.categories).get();
      final tiffinCategory = categories.firstWhere(
        (c) => c.name.toLowerCase() == 'tiffin',
        orElse: () => categories.firstWhere(
          (c) => c.name.toLowerCase() == 'food',
          orElse: () => categories.first,
        ),
      );

      final newTxId = await _expenseRepo.addTransaction(
        amountPaise: price,
        type: 'expense',
        categoryId: tiffinCategory.id,
        note: 'Tiffin - ${plan.mealType} (${plan.providerName})',
        date: date,
        source: 'tiffin',
        sourceRefId: logId,
      );

      await (_db.update(_db.tiffinLogs)..where((l) => l.id.equals(logId))).write(
        TiffinLogsCompanion(transactionId: Value(newTxId)),
      );
    }

    _eventBus.fire(TiffinReceived(
      planId: planId,
      date: date,
      pricePaise: price,
      mealType: plan.mealType,
    ));
  }

  /// Mark tiffin as skipped for a given date
  Future<void> markSkipped({
    required String planId,
    required String date,
  }) async {
    final existingLog = await (_db.select(_db.tiffinLogs)
          ..where((l) => l.planId.equals(planId) & l.date.equals(date)))
        .getSingleOrNull();

    if (existingLog != null) {
      // If there was an auto-created transaction, delete it
      if (existingLog.transactionId != null) {
        await _expenseRepo.deleteTransaction(existingLog.transactionId!);
      }

      await (_db.update(_db.tiffinLogs)
            ..where((l) => l.id.equals(existingLog.id)))
          .write(
        const TiffinLogsCompanion(
          status: Value('skipped'),
          transactionId: Value(null),
        ),
      );
    } else {
      await _db.into(_db.tiffinLogs).insert(
            TiffinLogsCompanion.insert(
              id: _uuid.v4(),
              planId: planId,
              date: date,
              status: const Value('skipped'),
            ),
          );
    }

    _eventBus.fire(TiffinSkipped(planId: planId, date: date));
  }

  /// Deactivate a plan
  Future<void> deletePlan(String id) async {
    await (_db.update(_db.tiffinPlans)..where((p) => p.id.equals(id))).write(
      const TiffinPlansCompanion(isActive: Value(false)),
    );
  }
}
