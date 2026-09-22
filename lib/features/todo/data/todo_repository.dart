/// Repository for To-Do List managing tasks, priorities, recurrence,
/// and action pipeline integration.
library;

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/core/events/domain_event.dart';
import 'package:bachelor_buddy/features/actions/action_intent.dart';

const _uuid = Uuid();

class TodoRepository {
  final AppDatabase _db;
  final EventBus _eventBus;

  TodoRepository(this._db, this._eventBus);

  /// Watch todos with optional filter (all, pending, completed)
  Stream<List<Todo>> watchTodos({bool? isDone, int? priorityFilter}) {
    final query = _db.select(_db.todos);
    if (isDone != null) {
      query.where((t) => t.isDone.equals(isDone));
    }
    if (priorityFilter != null) {
      query.where((t) => t.priority.equals(priorityFilter));
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.isDone),
      (t) => OrderingTerm.asc(t.priority),
      (t) => OrderingTerm.asc(t.dueAt),
      (t) => OrderingTerm.desc(t.createdAt),
    ]);
    return query.watch();
  }

  /// Add a new todo
  Future<String> addTodo({
    required String title,
    String notes = '',
    int? dueAt,
    int priority = 1, // 0=High, 1=Medium, 2=Low
    String recurrence = 'none', // none|daily|weekly|monthly
    ActionIntent? actionIntent,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    await _db.into(_db.todos).insert(
          TodosCompanion.insert(
            id: id,
            title: title,
            notes: Value(notes),
            dueAt: Value(dueAt),
            priority: Value(priority),
            recurrence: Value(recurrence),
            createdAt: now,
            actionType: Value(actionIntent?.type),
            actionPayloadJson: Value(
              actionIntent != null ? jsonEncode(actionIntent.payload) : null,
            ),
            actionStatus: Value(
              actionIntent != null ? 'suggested' : 'none',
            ),
          ),
        );

    _eventBus.fire(TodoCreated(todoId: id, title: title));
    return id;
  }

  /// Toggle completion of a todo
  Future<void> toggleTodo(String id) async {
    final todo = await (_db.select(_db.todos)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (todo == null) return;

    final newStatus = !todo.isDone;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    await (_db.update(_db.todos)..where((t) => t.id.equals(id))).write(
      TodosCompanion(
        isDone: Value(newStatus),
        doneAt: Value(newStatus ? now : null),
      ),
    );

    if (newStatus) {
      // Fire event for action runner & widget sync
      _eventBus.fire(TodoCompleted(
        todoId: todo.id,
        title: todo.title,
        actionType: todo.actionType,
        actionPayloadJson: todo.actionPayloadJson,
      ));

      // If recurring, generate next occurrence
      if (todo.recurrence != 'none' && todo.dueAt != null) {
        _generateNextOccurrence(todo);
      }
    }
  }

  /// Generate next occurrence for recurring tasks
  Future<void> _generateNextOccurrence(Todo parent) async {
    final currentDueDate = DateTime.fromMillisecondsSinceEpoch(parent.dueAt!);
    DateTime nextDueDate;

    switch (parent.recurrence) {
      case 'daily':
        nextDueDate = currentDueDate.add(const Duration(days: 1));
      case 'weekly':
        nextDueDate = currentDueDate.add(const Duration(days: 7));
      case 'monthly':
        nextDueDate = DateTime(
          currentDueDate.year,
          currentDueDate.month + 1,
          currentDueDate.day,
        );
      default:
        return;
    }

    final newId = _uuid.v4();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    await _db.into(_db.todos).insert(
          TodosCompanion.insert(
            id: newId,
            title: parent.title,
            notes: Value(parent.notes),
            dueAt: Value(nextDueDate.millisecondsSinceEpoch),
            priority: Value(parent.priority),
            recurrence: Value(parent.recurrence),
            parentTodoId: Value(parent.id),
            createdAt: now,
            actionType: Value(parent.actionType),
            actionPayloadJson: Value(parent.actionPayloadJson),
            actionStatus: Value(parent.actionType != null ? 'suggested' : 'none'),
          ),
        );
  }

  /// Update action status (confirmed / dismissed)
  Future<void> updateActionStatus(String id, String status) async {
    await (_db.update(_db.todos)..where((t) => t.id.equals(id))).write(
      TodosCompanion(actionStatus: Value(status)),
    );
  }

  /// Delete a todo
  Future<void> deleteTodo(String id) async {
    await (_db.delete(_db.todos)..where((t) => t.id.equals(id))).go();
  }
}
