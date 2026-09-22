/// Tiffin Tracker screen with daily status toggles, plan creation,
/// calendar navigation, and monthly billing totals.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bachelor_buddy/core/money.dart';
import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/features/tiffin/data/tiffin_repository.dart';
import 'package:bachelor_buddy/features/tiffin/domain/tiffin_providers.dart';

class TiffinScreen extends ConsumerStatefulWidget {
  const TiffinScreen({super.key});

  @override
  ConsumerState<TiffinScreen> createState() => _TiffinScreenState();
}

class _TiffinScreenState extends ConsumerState<TiffinScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedDateStr = ref.watch(tiffinSelectedDateProvider);
    final selectedDate = DateTime.tryParse(selectedDateStr) ?? DateTime.now();
    final plansAsync = ref.watch(tiffinPlansForSelectedDateProvider);
    final summaryAsync = ref.watch(tiffinMonthlySummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiffin Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                ref.read(tiffinSelectedDateProvider.notifier).state =
                    DateFormat('yyyy-MM-dd').format(picked);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Bill & Status Summary
            summaryAsync.when(
              data: (summary) => _TiffinMonthlyCard(summary: summary),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading summary: $err'),
              ),
            ),
            const SizedBox(height: 16),

            // Date Navigation Strip
            _DateStrip(
              selectedDate: selectedDate,
              onSelectDate: (d) {
                ref.read(tiffinSelectedDateProvider.notifier).state =
                    DateFormat('yyyy-MM-dd').format(d);
              },
            ),
            const SizedBox(height: 16),

            // Daily meal status header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meals for ${_formatDateHeader(selectedDate)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddPlanModal(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Plan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Meal cards for the date
            plansAsync.when(
              data: (plansWithLogs) {
                if (plansWithLogs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.lunch_dining,
                              size: 56, color: Colors.white24),
                          const SizedBox(height: 12),
                          Text(
                            'No active tiffin plans yet',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Set up a daily plan from your tiffin vendor to track meal deliveries and auto-log expenses.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white38),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => _showAddPlanModal(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Tiffin Plan'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: plansWithLogs.length,
                  itemBuilder: (context, index) {
                    final item = plansWithLogs[index];
                    return _TiffinMealCard(
                      plan: item.plan,
                      log: item.log,
                      dateStr: selectedDateStr,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlanModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Plan'),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) return 'Today';
    if (itemDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    if (itemDate == today.add(const Duration(days: 1))) return 'Tomorrow';
    return DateFormat('d MMM').format(date);
  }

  void _showAddPlanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _AddTiffinPlanSheet(),
    );
  }
}

class _TiffinMonthlyCard extends StatelessWidget {
  final TiffinMonthlySummary summary;

  const _TiffinMonthlyCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY TIFFIN BILL',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            color: Colors.white54,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Money.format(summary.totalBillPaise, showDecimal: false),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long,
                      color: AppColors.primary, size: 28),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatusMetric(
                  label: 'Received',
                  value: '${summary.totalReceived}',
                  color: AppColors.secondary,
                ),
                _StatusMetric(
                  label: 'Skipped',
                  value: '${summary.totalSkipped}',
                  color: AppColors.tertiary,
                ),
                _StatusMetric(
                  label: 'Pending',
                  value: '${summary.totalPending}',
                  color: Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Colors.white54),
        ),
      ],
    );
  }
}

class _DateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  const _DateStrip({
    required this.selectedDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    // Generate 7 days centered around selectedDate
    final days = List.generate(7, (i) {
      return selectedDate.add(Duration(days: i - 3));
    });

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = day.year == selectedDate.year &&
              day.month == selectedDate.month &&
              day.day == selectedDate.day;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelectDate(day),
            child: Container(
              width: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w400,
                      color: isSelected ? Colors.white : Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(day),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TiffinMealCard extends ConsumerWidget {
  final TiffinPlan plan;
  final TiffinLog? log;
  final String dateStr;

  const _TiffinMealCard({
    required this.plan,
    required this.log,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = log?.status ?? 'pending';
    final repo = ref.read(tiffinRepositoryProvider);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'received':
        statusColor = AppColors.secondary;
        statusText = 'Received (Auto-logged ₹${plan.pricePerTiffinPaise ~/ 100})';
        statusIcon = Icons.check_circle;
        break;
      case 'skipped':
        statusColor = AppColors.tertiary;
        statusText = 'Skipped (No Charge)';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.amber;
        statusText = 'Pending confirmation';
        statusIcon = Icons.hourglass_top;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    plan.mealType == 'dinner'
                        ? Icons.nightlife
                        : plan.mealType == 'lunch'
                            ? Icons.lunch_dining
                            : Icons.breakfast_dining,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${plan.mealType.toUpperCase()} • ${plan.providerName}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Daily @ ${plan.reminderTime} • ${Money.format(plan.pricePerTiffinPaise, showDecimal: false)}/meal',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: status == 'skipped'
                          ? AppColors.tertiary
                          : Colors.white70,
                      side: BorderSide(
                        color: status == 'skipped'
                            ? AppColors.tertiary
                            : Colors.white24,
                      ),
                    ),
                    onPressed: () async {
                      await repo.markSkipped(planId: plan.id, date: dateStr);
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: status == 'received'
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                    onPressed: () async {
                      await repo.markReceived(planId: plan.id, date: dateStr);
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Received'),
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

class _AddTiffinPlanSheet extends ConsumerStatefulWidget {
  const _AddTiffinPlanSheet();

  @override
  ConsumerState<_AddTiffinPlanSheet> createState() =>
      _AddTiffinPlanSheetState();
}

class _AddTiffinPlanSheetState extends ConsumerState<_AddTiffinPlanSheet> {
  final _providerController = TextEditingController();
  final _priceController = TextEditingController(text: '80');
  String _mealType = 'lunch';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 12, minute: 30);

  @override
  void dispose() {
    _providerController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Text('New Tiffin Plan',
                  style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _providerController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Vendor / Provider Name',
              hintText: 'e.g. Sai Tiffin Service',
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _mealType,
                  decoration: const InputDecoration(labelText: 'Meal Type'),
                  items: const [
                    DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                    DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                    DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                  ],
                  onChanged: (val) => setState(() => _mealType = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price per meal (₹)',
                    prefixText: '₹ ',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time),
            title: const Text('Daily Reminder Time'),
            subtitle: Text(_reminderTime.format(context)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _reminderTime,
              );
              if (picked != null) {
                setState(() => _reminderTime = picked);
              }
            },
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () async {
                final name = _providerController.text.trim();
                final pricePaise = Money.parse(_priceController.text);
                if (name.isEmpty || pricePaise <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter vendor and valid price')),
                  );
                  return;
                }

                final timeStr =
                    '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
                final todayStr =
                    DateFormat('yyyy-MM-dd').format(DateTime.now());

                final repo = ref.read(tiffinRepositoryProvider);
                await repo.createPlan(
                  providerName: name,
                  mealType: _mealType,
                  pricePerTiffinPaise: pricePaise,
                  activeWeekdaysMask: 127, // All days
                  reminderTime: timeStr,
                  startDate: todayStr,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Create Plan'),
            ),
          ),
        ],
      ),
    );
  }
}
