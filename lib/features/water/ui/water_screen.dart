/// Water Tracker screen with progress ring, quick glass logger,
/// 7-day streak history, and hydration settings modal.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/features/water/domain/water_providers.dart';
import 'package:bachelor_buddy/features/water/data/water_repository.dart';

class WaterScreen extends ConsumerWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(todayWaterStatusProvider);
    final historyAsync = ref.watch(weeklyWaterHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showSettingsModal(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Main Progress Card with Circular Ring
            statusAsync.when(
              data: (status) => _WaterProgressCard(status: status),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
            const SizedBox(height: 20),

            // Quick Add Buttons
            statusAsync.when(
              data: (status) => _QuickAddButtons(glassMl: status.glassMl),
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // 7-Day History Chart
            historyAsync.when(
              data: (history) => _WeeklyHistoryCard(history: history),
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),

            // Today's Logs Timeline
            statusAsync.when(
              data: (status) => _TodayLogsList(status: status),
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _WaterSettingsSheet(),
    );
  }
}

class _WaterProgressCard extends StatelessWidget {
  final TodayWaterStatus status;

  const _WaterProgressCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final percent = (status.progress * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: status.progress,
                      strokeWidth: 14,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.water_drop,
                          color: AppColors.secondary, size: 36),
                      const SizedBox(height: 4),
                      Text(
                        '$percent%',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        '${status.intakeMl} / ${status.goalMl} ml',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_drink,
                    size: 18, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  '${status.glassesDrank} of ${status.totalGlasses} glasses drank',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddButtons extends ConsumerWidget {
  final int glassMl;

  const _QuickAddButtons({required this.glassMl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(waterRepositoryProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.black87,
                ),
                onPressed: () async {
                  await repo.addWater(glassMl);
                },
                icon: const Icon(Icons.local_drink),
                label: Text(
                  '+1 Glass (${glassMl}ml)',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                ),
                onPressed: () async {
                  await repo.addWater(500);
                },
                icon: const Icon(Icons.water, size: 18),
                label: const Text(
                  '+500ml',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyHistoryCard extends StatelessWidget {
  final List<DailyWaterSummary> history;

  const _WeeklyHistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Last 7 Days',
                    style: Theme.of(context).textTheme.titleSmall),
                Text(
                  'Goal: 2.5L / day',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: history.map((day) {
                final ratio = day.goalMl > 0
                    ? (day.totalMl / day.goalMl).clamp(0.0, 1.0)
                    : 0.0;
                final isReached = day.reachedGoal;
                final dayLabel = DateFormat('E').format(day.date).substring(0, 1);

                return Column(
                  children: [
                    Container(
                      width: 28,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 28,
                        height: 80 * ratio,
                        decoration: BoxDecoration(
                          color: isReached
                              ? AppColors.secondary
                              : AppColors.secondary.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isReached ? FontWeight.bold : FontWeight.normal,
                        color: isReached ? Colors.white : Colors.white54,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayLogsList extends ConsumerWidget {
  final TodayWaterStatus status;

  const _TodayLogsList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (status.logs.isEmpty) {
      return const SizedBox.shrink();
    }

    final repo = ref.read(waterRepositoryProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today\'s History',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: status.logs.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final log = status.logs[index];
                final time =
                    DateTime.fromMillisecondsSinceEpoch(log.loggedAt).toLocal();

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.water_drop,
                      color: AppColors.secondary, size: 20),
                  title: Text('${log.amountMl} ml'),
                  subtitle: Text(DateFormat('h:mm a').format(time)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.white38),
                    onPressed: () async {
                      await repo.deleteWaterLog(log.id);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterSettingsSheet extends ConsumerStatefulWidget {
  const _WaterSettingsSheet();

  @override
  ConsumerState<_WaterSettingsSheet> createState() =>
      _WaterSettingsSheetState();
}

class _WaterSettingsSheetState extends ConsumerState<_WaterSettingsSheet> {
  final _goalController = TextEditingController();
  final _glassController = TextEditingController();
  int _interval = 60;
  bool _enabled = true;
  bool _initialized = false;

  @override
  void dispose() {
    _goalController.dispose();
    _glassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(waterSettingsProvider);

    return settingsAsync.when(
      data: (settings) {
        if (!_initialized) {
          _goalController.text = '${settings.dailyGoalMl}';
          _glassController.text = '${settings.glassMl}';
          _interval = settings.reminderIntervalMin;
          _enabled = settings.remindersEnabled;
          _initialized = true;
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Water Goal & Reminders',
                      style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _goalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Daily Goal (ml)',
                  suffixText: 'ml',
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _glassController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Glass Size (ml)',
                  suffixText: 'ml',
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                initialValue: _interval,
                decoration: const InputDecoration(labelText: 'Reminder Interval'),
                items: const [
                  DropdownMenuItem(value: 30, child: Text('Every 30 mins')),
                  DropdownMenuItem(value: 45, child: Text('Every 45 mins')),
                  DropdownMenuItem(value: 60, child: Text('Every 1 hour')),
                  DropdownMenuItem(value: 90, child: Text('Every 1.5 hours')),
                  DropdownMenuItem(value: 120, child: Text('Every 2 hours')),
                ],
                onChanged: (val) => setState(() => _interval = val!),
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable Reminders'),
                subtitle: const Text('Notifications during active daytime'),
                value: _enabled,
                onChanged: (val) => setState(() => _enabled = val),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () async {
                    final goal = int.tryParse(_goalController.text) ?? 2500;
                    final glass = int.tryParse(_glassController.text) ?? 200;

                    final repo = ref.read(waterRepositoryProvider);
                    await repo.updateSettings(
                      dailyGoalMl: goal,
                      glassMl: glass,
                      dayStart: settings.dayStart,
                      dayEnd: settings.dayEnd,
                      reminderIntervalMin: _interval,
                      remindersEnabled: _enabled,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Settings'),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
