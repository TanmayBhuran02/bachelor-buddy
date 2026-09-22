/// Drift database tables for Bachelor Buddy.
/// All IDs are text UUIDs. Timestamps stored as UTC epoch milliseconds.
/// Dates stored as YYYY-MM-DD text. Money stored as integer paise.
library;

import 'package:drift/drift.dart';

// ─── Categories ────────────────────────────────────────────────────────────

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get iconKey => text().withDefault(const Constant('category'))();
  TextColumn get colorHex => text().withDefault(const Constant('#6C63FF'))();
  TextColumn get kind => text()(); // 'expense' | 'income'
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Transactions ──────────────────────────────────────────────────────────

class Transactions extends Table {
  TextColumn get id => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get type => text()(); // 'expense' | 'income'
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get source =>
      text().withDefault(const Constant('manual'))(); // manual|tiffin|todo_action
  TextColumn get sourceRefId => text().nullable()();
  BoolColumn get isShared =>
      boolean().withDefault(const Constant(false))(); // roommate split tag
  IntColumn get createdAt => integer()(); // UTC epoch ms

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Budgets ───────────────────────────────────────────────────────────────

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get month => text()(); // YYYY-MM
  TextColumn get categoryId => text().nullable()(); // null = overall budget
  IntColumn get limitPaise => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {month, categoryId},
      ];
}

// ─── Recurring Expenses ────────────────────────────────────────────────────

class RecurringExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get amountPaise => integer()();
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get dayOfMonth => integer()(); // 1-31, clamped to month length
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get lastGeneratedMonth =>
      text().withDefault(const Constant(''))(); // YYYY-MM

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Tiffin Plans ──────────────────────────────────────────────────────────

class TiffinPlans extends Table {
  TextColumn get id => text()();
  TextColumn get providerName => text()();
  TextColumn get mealType => text()(); // breakfast|lunch|dinner
  IntColumn get pricePerTiffinPaise => integer()();
  IntColumn get activeWeekdaysMask => integer()(); // bitmask 1-127 (Mon=1..Sun=64)
  TextColumn get reminderTime =>
      text().withDefault(const Constant('12:00'))(); // HH:mm
  TextColumn get startDate => text()(); // YYYY-MM-DD
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Tiffin Logs ───────────────────────────────────────────────────────────

class TiffinLogs extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text().references(TiffinPlans, #id)();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending|received|skipped
  IntColumn get priceOverridePaise => integer().nullable()();
  TextColumn get transactionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {planId, date},
      ];
}

// ─── Todos ─────────────────────────────────────────────────────────────────

class Todos extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get dueAt => integer().nullable()(); // UTC epoch ms
  IntColumn get priority =>
      integer().withDefault(const Constant(1))(); // 0=high, 1=medium, 2=low
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  IntColumn get doneAt => integer().nullable()(); // UTC epoch ms
  IntColumn get createdAt => integer()(); // UTC epoch ms
  TextColumn get actionType => text().nullable()(); // e.g. 'create_expense'
  TextColumn get actionPayloadJson => text().nullable()(); // JSON
  TextColumn get actionStatus => text().withDefault(
      const Constant('none'))(); // none|suggested|confirmed|executed|dismissed
  TextColumn get recurrence =>
      text().withDefault(const Constant('none'))(); // none|daily|weekly|monthly
  TextColumn get parentTodoId => text().nullable()(); // for recurring instances

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Water Settings ────────────────────────────────────────────────────────

class WaterSettings extends Table {
  IntColumn get id =>
      integer().withDefault(const Constant(1))(); // single row
  IntColumn get dailyGoalMl =>
      integer().withDefault(const Constant(2500))();
  IntColumn get glassMl => integer().withDefault(const Constant(200))();
  TextColumn get dayStart =>
      text().withDefault(const Constant('07:00'))(); // HH:mm
  TextColumn get dayEnd =>
      text().withDefault(const Constant('22:00'))(); // HH:mm
  IntColumn get reminderIntervalMin =>
      integer().withDefault(const Constant(60))();
  BoolColumn get remindersEnabled =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Water Logs ────────────────────────────────────────────────────────────

class WaterLogs extends Table {
  TextColumn get id => text()();
  IntColumn get amountMl => integer()();
  IntColumn get loggedAt => integer()(); // UTC epoch ms

  @override
  Set<Column> get primaryKey => {id};
}

// ─── App Settings ──────────────────────────────────────────────────────────

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ─── Debug Logs ────────────────────────────────────────────────────────────

class DebugLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get level => text()(); // info|warning|error
  TextColumn get message => text()();
  IntColumn get timestamp => integer()(); // UTC epoch ms
  TextColumn get context => text().withDefault(const Constant(''))();
}
