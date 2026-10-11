/// To-Do list screen with task filtering, completion checkboxes,
/// priority badges, action indicators, edit and delete actions.
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
        title: const Text('TO-DO LIST'),
      ),
      body: Column(
        children: [
          // Filter tabs: Pending, Completed, All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'PENDING',
                  isSelected: activeFilter == false,
                  onSelected: () =>
                      ref.read(todoFilterProvider.notifier).state = false,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'COMPLETED',
                  isSelected: activeFilter == true,
                  onSelected: () =>
                      ref.read(todoFilterProvider.notifier).state = true,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'ALL',
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
                        Icon(Icons.checklist, size: 48, color: AppColors.border(context)),
                        const SizedBox(height: 16),
                        Text(
                          activeFilter == true
                              ? 'NO COMPLETED TASKS'
                              : 'NO TASKS TO DO',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: AppColors.textMuted(context)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to create a task with smart automations',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSubtle(context)),
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
        label: const Text('ADD TASK'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNeo = AppColors.styleOf(context) == AppThemeStyle.neobrutalism;
    final selectedBg = isNeo
        ? AppColors.neoYellow
        : (isDark ? AppColors.paperWhite : AppColors.markerBlack);
    final selectedText = isNeo
        ? const Color(0xFF000000)
        : (isDark ? AppColors.markerBlack : AppColors.paperWhite);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: selectedBg,
      labelStyle: TextStyle(
        color: isSelected ? selectedText : AppColors.textMuted(context),
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        fontSize: 10,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _TodoItemTile extends ConsumerWidget {
  final Todo todo;

  const _TodoItemTile({required this.todo});

  /// Whether this is a completed recurring task from a past date (locked).
  bool _isLockedPastRecurring() {
    if (!todo.isDone || todo.recurrence == 'none' || todo.doneAt == null) {
      return false;
    }
    final doneDate = DateTime.fromMillisecondsSinceEpoch(todo.doneAt!);
    final now = DateTime.now();
    final doneDayStart = DateTime(doneDate.year, doneDate.month, doneDate.day);
    final todayStart = DateTime(now.year, now.month, now.day);
    return doneDayStart.isBefore(todayStart);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(todoRepositoryProvider);
    final isLocked = _isLockedPastRecurring();
    final isNeo = AppColors.styleOf(context) == AppThemeStyle.neobrutalism;

    Color priorityColor = switch (todo.priority) {
      0 => isNeo ? AppColors.neoPink : AppColors.tertiary,
      1 => isNeo ? AppColors.neoOrange : AppColors.warning,
      _ => isNeo ? AppColors.neoCyan : AppColors.secondary,
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
              '// EXPENSE: ${Money.format(amountPaise, showDecimal: false)} in $cat';
        }
      } catch (_) {}
    }

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('DELETE TASK'),
            content: Text('Delete "${todo.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('DELETE',
                    style: TextStyle(color: AppColors.tertiary)),
              ),
            ],
          ),
        ) ?? false;
      },
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: () => context.push('/todo/edit/${todo.id}'),
          onLongPress: () => _showOptionsSheet(context, ref),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox — disabled if locked past recurring
                Checkbox(
                  value: todo.isDone,
                  activeColor: AppColors.secondary,
                  onChanged: isLocked
                      ? null
                      : (_) async {
                          final success = await repo.toggleTodo(todo.id);
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Cannot uncheck a task completed on a past date'),
                              ),
                            );
                          }
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
                                  .bodyMedium
                                  ?.copyWith(
                                    decoration: todo.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: todo.isDone
                                        ? AppColors.textSubtle(context)
                                        : AppColors.text(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          // Priority square dot
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: priorityColor,
                              borderRadius: BorderRadius.circular(1),
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
                              ?.copyWith(color: AppColors.textMuted(context)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),

                      // Badges row (Due Date, Action chip, Recurrence, Lock)
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
                                color: AppColors.surface(context),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.repeat,
                                      size: 10, color: AppColors.textMuted(context)),
                                  const SizedBox(width: 4),
                                  Text(
                                    todo.recurrence.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 9, color: AppColors.textMuted(context), letterSpacing: 0.5),
                                  ),
                                ],
                              ),
                            ),
                          if (isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.textSubtle(context).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_outline,
                                      size: 10, color: AppColors.textSubtle(context)),
                                  const SizedBox(width: 3),
                                  Text(
                                    'LOCKED',
                                    style: TextStyle(
                                        fontSize: 9, color: AppColors.textSubtle(context), letterSpacing: 0.5),
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
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                todo.actionStatus == 'executed'
                                    ? '// LOGGED'
                                    : actionLabel,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: todo.actionStatus == 'executed'
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  letterSpacing: 0.5,
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
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, WidgetRef ref) {
    final repo = ref.read(todoRepositoryProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('EDIT TASK'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/todo/edit/${todo.id}');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.tertiary),
              title: Text('DELETE TASK',
                  style: TextStyle(color: AppColors.tertiary)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (dlg) => AlertDialog(
                    title: const Text('DELETE TASK'),
                    content: Text('Delete "${todo.title}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dlg, false),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dlg, true),
                        child: Text('DELETE',
                            style: TextStyle(color: AppColors.tertiary)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await repo.deleteTodo(todo.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${todo.title} deleted')),
                    );
                  }
                }
              },
            ),
          ],
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
            ? AppColors.warning
            : AppColors.textMuted(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event, size: 10, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            isToday
                ? 'TODAY, ${DateFormat('h:mm a').format(due).toUpperCase()}'
                : DateFormat('d MMM, h:mm a').format(due).toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: badgeColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
