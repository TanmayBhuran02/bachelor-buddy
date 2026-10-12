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
      key: const ValueKey('home_scaffold'),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('BACHELOR BUDDY'),
            Text(
              _greeting().toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.styleOf(context) == AppThemeStyle.neobrutalism
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.neoYellow
                            : const Color(0xFF666666))
                        : AppColors.kraftBrown,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const ValueKey('home_settings_button'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Budget Overview Card
          _LiveBudgetOverviewCard(key: const ValueKey('home_budget_overview')),
          const SizedBox(height: 8),

          // Quick Actions
          _QuickActionsRow(key: const ValueKey('home_quick_actions')),
          const SizedBox(height: 8),

          // Today's Tiffin
          _LiveTiffinStatusCard(key: const ValueKey('home_tiffin_status')),
          const SizedBox(height: 4),

          // Water Progress
          _LiveWaterProgressCard(key: const ValueKey('home_water_progress')),
          const SizedBox(height: 4),

          // Top Tasks
          _LiveTopTasksCard(key: const ValueKey('home_top_tasks')),
          const SizedBox(height: 80), // Bottom padding for nav bar
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'good morning, buddy';
    if (hour < 17) return 'good afternoon, buddy';
    return 'good evening, buddy';
  }
}

class _LiveBudgetOverviewCard extends ConsumerWidget {
  const _LiveBudgetOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(currentMonthBudgetOverviewProvider);

    return overviewAsync.when(
      data: (overview) {
        final hasLimit = overview.limitPaise > 0;
        final progress = hasLimit ? overview.percentage.clamp(0.0, 1.0) : 0.0;

        Color progressColor;
        if (overview.percentage > 0.9) {
          progressColor = AppColors.tertiary;
        } else if (overview.percentage > 0.75) {
          progressColor = AppColors.warning;
        } else {
          progressColor = AppColors.secondary;
        }

        return Card(
          key: const ValueKey('budget_overview_card'),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(2),
            onTap: () => context.push('/budget'),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MONTHLY BUDGET',
                          style: Theme.of(context).textTheme.titleMedium),
                      Row(
                        children: [
                          Text('DETAILS →',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted(context),
                                  letterSpacing: 1)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          Money.format(overview.spentPaise, showDecimal: false),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasLimit)
                        Flexible(
                          child: Text(
                            ' / ${Money.format(overview.limitPaise, showDecimal: false)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.textSubtle(context)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.track(context),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasLimit
                        ? 'Safe to spend: ${Money.format(overview.safeToSpendPerDayPaise, showDecimal: false)}/day (${overview.remainingDays} days left)'
                        : 'Tap to set monthly budget limit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: hasLimit
                              ? AppColors.secondary
                              : AppColors.textMuted(context),
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
  const _QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('ADD EXP', Icons.account_balance_wallet, '/expenses/new'),
      ('TIFFIN', Icons.lunch_dining, '/tiffin'),
      ('ADD TASK', Icons.add_task, '/todo/new'),
      ('WATER', Icons.water_drop, '/water'),
    ];

    final isNeo = AppColors.styleOf(context) == AppThemeStyle.neobrutalism;
    final neoColors = [
      AppColors.neoPink,
      AppColors.neoOrange,
      AppColors.neoYellow,
      AppColors.neoCyan,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: actions.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          final iconBg = isNeo ? neoColors[i % neoColors.length] : AppColors.surface(context);
          final iconColor = isNeo ? const Color(0xFF000000) : AppColors.kraftBrown;

          return Flexible(
            child: GestureDetector(
              onTap: () => context.push(a.$3),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(isNeo ? 6 : 2),
                      border: Border.all(
                        color: AppColors.border(context),
                        width: isNeo ? 2.5 : 1.5,
                      ),
                      boxShadow: isNeo
                          ? const [
                              BoxShadow(
                                color: Color(0xFF000000),
                                offset: Offset(2.5, 2.5),
                                blurRadius: 0,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(a.$2, color: iconColor, size: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.$1,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.text(context),
                          letterSpacing: 0.8,
                          fontWeight: isNeo ? FontWeight.w800 : FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LiveTiffinStatusCard extends ConsumerWidget {
  const _LiveTiffinStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(tiffinPlansForSelectedDateProvider);

    return Card(
      key: const ValueKey('tiffin_status_card'),
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
                    Text("TODAY'S TIFFIN",
                        style: Theme.of(context).textTheme.titleSmall),
                  ],
                ),
                GestureDetector(
                  onTap: () => context.push('/tiffin'),
                  child: Text('VIEW ALL →',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted(context),
                          letterSpacing: 1)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            plansAsync.when(
              data: (plans) {
                if (plans.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No active tiffin plans. Tap to configure.',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textSubtle(context)),
                    ),
                  );
                }

                return Column(
                  children: plans.map((p) {
                    final isReceived = p.log?.status == 'received';
                    final isSkipped = p.log?.status == 'skipped';
                    final status = isReceived
                        ? 'RECEIVED'
                        : isSkipped
                            ? 'SKIPPED'
                            : 'PENDING';

                    final statusColor = isReceived
                        ? AppColors.tiffinReceived(context)
                        : isSkipped
                            ? AppColors.tertiary
                            : AppColors.warning;

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
                            color: statusColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${p.plan.mealType.toUpperCase()} — ${p.plan.providerName}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              status,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: statusColor,
                                    letterSpacing: 0.8,
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
  const _LiveWaterProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(todayWaterStatusProvider);

    return Card(
      key: const ValueKey('water_progress_card'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: waterAsync.when(
          data: (status) {
            final percent = (status.progress * 100).toInt();

            return Row(
              children: [
                // Raw square progress indicator
                SizedBox(
                  width: 58,
                  height: 58,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppColors.border(context), width: 1.5),
                    ),
                    child: Center(
                      child: Text('$percent%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.secondary,
                              )),
                    ),
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
                        '${status.glassesDrank} glasses today',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted(context),
                            ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  key: const ValueKey('water_add_glass_button'),
                  onPressed: () async {
                    final repo = ref.read(waterRepositoryProvider);
                    await repo.addWater(status.glassMl);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.12),
                    foregroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
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
  const _LiveTopTasksCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todosStreamProvider);

    return Card(
      key: const ValueKey('top_tasks_card'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TASKS DUE TODAY',
                    style: Theme.of(context).textTheme.titleSmall),
                GestureDetector(
                  onTap: () => context.push('/todo'),
                  child: Text('VIEW ALL →',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted(context),
                          letterSpacing: 1)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            todosAsync.when(
              data: (todos) {
                final pendingTodos =
                    todos.where((t) => !t.isDone).take(3).toList();

                if (pendingTodos.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('All tasks completed.',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSubtle(context))),
                  );
                }

                final repo = ref.read(todoRepositoryProvider);

                return Column(
                  children: pendingTodos.map((t) {
                    final color = switch (t.priority) {
                      0 => AppColors.tertiary,
                      1 => AppColors.warning,
                      _ => AppColors.secondary,
                    };

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
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
