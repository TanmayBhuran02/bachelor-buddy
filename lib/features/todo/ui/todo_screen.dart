/// To-Do list screen with task filtering, completion checkboxes,
/// priority badges, action indicators, and delete actions.
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/core/money.dart';
import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/features/todo/domain/todo_providers.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure ActionRunner is active to process TodoCompleted events
    ref.watch(actionRunnerProvider);

    final todosAsync = ref.watch(todosStreamProvider);
    final activeFilter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        children: [
          // Filter tabs: Pending, Completed, All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Pending',
                  isSelected: activeFilter == false,
                  onSelected: () =>
                      ref.read(todoFilterProvider.notifier).state = false,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  isSelected: activeFilter == true,
                  onSelected: () =>
                      ref.read(todoFilterProvider.notifier).state = true,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'All',
                  isSelected: activeFilter == null,
                  onSelected: () =>
                      ref.read(todoFilterProvider.notifier).state = null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Todos list
          Expanded(
            child: todosAsync.when(
              data: (todos) {
                if (todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checklist, size: 64, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text(
                          activeFilter == true
                              ? 'No completed tasks'
                              : 'No tasks to do!',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white60),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to create a task with smart automations',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white38),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return _TodoItemTile(todo: todo);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/todo/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white60,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

class _TodoItemTile extends ConsumerWidget {
  final Todo todo;

  const _TodoItemTile({required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(todoRepositoryProvider);

    Color priorityColor = switch (todo.priority) {
      0 => AppColors.tertiary,
      1 => Colors.amber,
      _ => AppColors.secondary,
    };

    String? actionLabel;
    if (todo.actionType == 'create_expense' && todo.actionPayloadJson != null) {
      try {
        final payload =
            jsonDecode(todo.actionPayloadJson!) as Map<String, dynamic>;
        final amountPaise = payload['amountPaise'] as int?;
        final cat = payload['categoryHint'] as String? ?? 'Expense';
        if (amountPaise != null) {
          actionLabel =
              '⚡ Auto-Expense: ${Money.format(amountPaise, showDecimal: false)} in $cat';
        }
      } catch (_) {}
    }

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.tertiary.withValues(alpha: 0.2),
        child: const Icon(Icons.delete_outline, color: AppColors.tertiary),
      ),
      onDismissed: (_) async {
        await repo.deleteTodo(todo.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${todo.title} deleted')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Checkbox(
                value: todo.isDone,
                activeColor: AppColors.secondary,
                onChanged: (_) async {
                  await repo.toggleTodo(todo.id);
                },
              ),
              const SizedBox(width: 8),

              // Title and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            todo.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  decoration: todo.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: todo.isDone
                                      ? Colors.white38
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        // Priority dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: priorityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    if (todo.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.notes,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Badges row (Due Date, Action chip, Recurrence)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (todo.dueAt != null)
                          _DueBadge(dueEpoch: todo.dueAt!, isDone: todo.isDone),
                        if (todo.recurrence != 'none')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.repeat,
                                    size: 10, color: Colors.white54),
                                const SizedBox(width: 4),
                                Text(
                                  todo.recurrence,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        if (actionLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (todo.actionStatus == 'executed'
                                      ? AppColors.secondary
                                      : AppColors.primary)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              todo.actionStatus == 'executed'
                                  ? '✓ Expense Logged'
                                  : actionLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: todo.actionStatus == 'executed'
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DueBadge extends StatelessWidget {
  final int dueEpoch;
  final bool isDone;

  const _DueBadge({required this.dueEpoch, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final due = DateTime.fromMillisecondsSinceEpoch(dueEpoch);
    final now = DateTime.now();
    final isOverdue = !isDone && due.isBefore(now);
    final isToday = due.year == now.year &&
        due.month == now.month &&
        due.day == now.day;

    Color badgeColor = isOverdue
        ? AppColors.tertiary
        : isToday
            ? Colors.amber
            : Colors.white54;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, size: 10, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            isToday
                ? 'Today, ${DateFormat('h:mm a').format(due)}'
                : DateFormat('d MMM, h:mm a').format(due),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
