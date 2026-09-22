/// Home dashboard screen — aggregated view of all features with live data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/core/money.dart';
import 'package:bachelor_buddy/features/budget/domain/budget_providers.dart';
import 'package:bachelor_buddy/features/tiffin/domain/tiffin_providers.dart';
import 'package:bachelor_buddy/features/water/domain/water_providers.dart';
import 'package:bachelor_buddy/features/todo/domain/todo_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure ActionRunner is active
    ref.watch(actionRunnerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bachelor Buddy'),
            Text(
              'Good ${_greeting()}, Buddy',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Budget Overview Card
          _LiveBudgetOverviewCard(),
          const SizedBox(height: 8),

          // Quick Actions
          _QuickActionsRow(),
          const SizedBox(height: 8),

          // Today's Tiffin
          _LiveTiffinStatusCard(),
          const SizedBox(height: 4),

          // Water Progress
          _LiveWaterProgressCard(),
          const SizedBox(height: 4),

          // Top Tasks
          _LiveTopTasksCard(),
          const SizedBox(height: 80), // Bottom padding for nav bar
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _LiveBudgetOverviewCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(budgetOverviewProvider);

    return overviewAsync.when(
      data: (overview) {
        final hasLimit = overview.limitPaise > 0;
        final progress = hasLimit ? overview.percentage.clamp(0.0, 1.0) : 0.0;

        Color progressColor;
        if (overview.percentage > 0.9) {
          progressColor = AppColors.tertiary;
        } else if (overview.percentage > 0.75) {
          progressColor = Colors.amber;
        } else {
          progressColor = AppColors.secondary;
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => context.push('/budget'),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Monthly Budget',
                          style: Theme.of(context).textTheme.titleMedium),
                      Row(
                        children: [
                          Text('Details',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.primary)),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios,
                              size: 12, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        Money.format(overview.spentPaise, showDecimal: false),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (hasLimit)
                        Text(
                          ' / ${Money.format(overview.limitPaise, showDecimal: false)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white38),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasLimit
                        ? 'Safe to spend: ${Money.format(overview.safeToSpendPerDayPaise, showDecimal: false)}/day (${overview.remainingDays} days left)'
                        : 'Tap to set monthly budget limit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: hasLimit ? AppColors.secondary : Colors.white54,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Add Expense', Icons.account_balance_wallet, '/expenses/new'),
      ('Tiffin', Icons.lunch_dining, '/tiffin'),
      ('Add Task', Icons.add_task, '/todo/new'),
      ('Log Water', Icons.water_drop, '/water'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.map((a) {
          return GestureDetector(
            onTap: () => context.push(a.$3),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(a.$2, color: AppColors.primary, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  a.$1,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LiveTiffinStatusCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(tiffinPlansForSelectedDateProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lunch_dining,
                        color: AppColors.secondary, size: 20),
                    const SizedBox(width: 8),
                    Text("Today's Tiffin",
                        style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/tiffin'),
                  child: const Text('View All',
                      style: TextStyle(fontSize: 12, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            plansAsync.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No active tiffin plans. Tap to configure.',
                      style: TextStyle(fontSize: 12, color: Colors.white38),
                    ),
                  );
                }

                return Column(
                  children: plans.map((p) {
                    final isReceived = p.log?.status == 'received';
                    final isSkipped = p.log?.status == 'skipped';
                    final status = isReceived
                        ? 'Received'
                        : isSkipped
                            ? 'Skipped'
                            : 'Pending';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            isReceived
                                ? Icons.check_circle
                                : isSkipped
                                    ? Icons.cancel
                                    : Icons.pending,
                            color: isReceived
                                ? AppColors.secondary
                                : isSkipped
                                    ? AppColors.tertiary
                                    : Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${p.plan.mealType.toUpperCase()} - ${p.plan.providerName}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isReceived
                                      ? AppColors.secondary
                                      : isSkipped
                                          ? AppColors.tertiary
                                          : Colors.amber)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: isReceived
                                        ? AppColors.secondary
                                        : isSkipped
                                            ? AppColors.tertiary
                                            : Colors.amber,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveWaterProgressCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(todayWaterStatusProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: waterAsync.when(
          data: (status) {
            final percent = (status.progress * 100).toInt();

            return Row(
              children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: status.progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.secondary),
                      ),
                      Text('$percent%',
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${status.intakeMl} / ${status.goalMl} ml',
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        '${status.glassesDrank} glasses drank today',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white60,
                            ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    final repo = ref.read(waterRepositoryProvider);
                    await repo.addWater(status.glassMl);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        AppColors.secondary.withValues(alpha: 0.15),
                    foregroundColor: AppColors.secondary,
                  ),
                  child: Text('+${status.glassMl}ml'),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 58,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, s) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _LiveTopTasksCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosStreamProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tasks Due Today',
                    style: Theme.of(context).textTheme.titleSmall),
                GestureDetector(
                  onTap: () => context.push('/todo'),
                  child: const Text('View All',
                      style: TextStyle(fontSize: 12, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            todosAsync.when(
              data: (todos) {
                final pendingTodos =
                    todos.where((t) => !t.isDone).take(3).toList();

                if (pendingTodos.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('All tasks completed! 🎉',
                        style: TextStyle(fontSize: 12, color: Colors.white54)),
                  );
                }

                final repo = ref.read(todoRepositoryProvider);

                return Column(
                  children: pendingTodos.map((t) {
                    final color = switch (t.priority) {
                      0 => AppColors.tertiary,
                      1 => Colors.amber,
                      _ => AppColors.secondary,
                    };

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: color),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: t.isDone,
                            onChanged: (_) async {
                              await repo.toggleTodo(t.id);
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          Expanded(
                            child: Text(
                              t.title,
                              style: Theme.of(context).textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
