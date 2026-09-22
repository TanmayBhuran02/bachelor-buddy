/// Main Drift database definition with DAOs, seed data, and migrations.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables/all_tables.dart';

part 'app_database.g.dart';

const _uuid = Uuid();

@DriftDatabase(tables: [
  Categories,
  Transactions,
  Budgets,
  RecurringExpenses,
  TiffinPlans,
  TiffinLogs,
  Todos,
  WaterSettings,
  WaterLogs,
  AppSettings,
  DebugLogs,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // For testing
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedData();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations go here
        },
      );

  /// Seed default categories and water settings
  Future<void> _seedData() async {
    final defaultCategories = [
      ('Food', 'restaurant', '#FF9800', 'expense'),
      ('Tiffin', 'lunch_dining', '#009688', 'expense'),
      ('Rent', 'home', '#795548', 'expense'),
      ('Travel', 'directions_car', '#2196F3', 'expense'),
      ('Groceries', 'shopping_cart', '#4CAF50', 'expense'),
      ('Utilities', 'bolt', '#FF5722', 'expense'),
      ('Recharge/Bills', 'phone_android', '#9C27B0', 'expense'),
      ('Entertainment', 'movie', '#E91E63', 'expense'),
      ('Health', 'local_hospital', '#F44336', 'expense'),
      ('Shopping', 'shopping_bag', '#3F51B5', 'expense'),
      ('Other', 'more_horiz', '#607D8B', 'expense'),
      ('Salary', 'account_balance_wallet', '#4CAF50', 'income'),
      ('Freelance', 'work', '#2196F3', 'income'),
      ('Other Income', 'attach_money', '#009688', 'income'),
    ];

    for (final (name, icon, color, kind) in defaultCategories) {
      await into(categories).insert(CategoriesCompanion.insert(
        id: _uuid.v4(),
        name: name,
        iconKey: Value(icon),
        colorHex: Value(color),
        kind: kind,
        isDefault: const Value(true),
      ));
    }

    // Seed default water settings
    await into(waterSettings).insert(WaterSettingsCompanion.insert());

    // Set first-run flag
    await into(appSettings).insert(AppSettingsCompanion.insert(
      key: 'first_run',
      value: 'true',
    ));
    await into(appSettings).insert(AppSettingsCompanion.insert(
      key: 'theme_mode',
      value: 'dark',
    ));
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'bachelor_buddy',
  );
}
