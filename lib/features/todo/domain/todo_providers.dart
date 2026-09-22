/// Riverpod providers for To-Do list and action runner integration.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bachelor_buddy/providers.dart';
import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/features/expenses/domain/expense_providers.dart';
import 'package:bachelor_buddy/features/actions/action_runner.dart';
import 'package:bachelor_buddy/features/actions/create_expense_handler.dart';
import 'package:bachelor_buddy/features/todo/data/todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final eventBus = ref.watch(eventBusProvider);
  return TodoRepository(db, eventBus);
});

/// Filter state: null=all, false=pending, true=completed
final todoFilterProvider = StateProvider<bool?>((ref) => false); // default show pending

/// Stream of todos matching current filter
final todosStreamProvider = StreamProvider<List<Todo>>((ref) {
  final repo = ref.watch(todoRepositoryProvider);
  final filter = ref.watch(todoFilterProvider);
  return repo.watchTodos(isDone: filter);
});

/// ActionRunner provider that hooks into the event bus
final actionRunnerProvider = Provider<ActionRunner>((ref) {
  final registry = ref.watch(actionRegistryProvider);
  final eventBus = ref.watch(eventBusProvider);
  final db = ref.watch(databaseProvider);
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final todoRepo = ref.watch(todoRepositoryProvider);

  // Register create_expense handler
  registry.register(CreateExpenseActionHandler(expenseRepo, todoRepo, db));

  final runner = ActionRunner(registry: registry, eventBus: eventBus);
  ref.onDispose(() => runner.dispose());
  return runner;
});
