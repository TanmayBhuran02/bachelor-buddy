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
        title: const Text('TIFFIN TRACKER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Month Calendar',
            onPressed: () => _showMonthCalendarModal(context),
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
              data: (summary) => _TiffinMonthlyCard(
                summary: summary,
                onOpenCalendar: () => _showMonthCalendarModal(context),
              ),
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
                    'MEALS FOR ${_formatDateHeader(selectedDate)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(letterSpacing: 0.8),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddPlanModal(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('NEW PLAN'),
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
                              size: 48, color: AppColors.border(context)),
                          const SizedBox(height: 12),
                          Text(
                            'NO ACTIVE TIFFIN PLANS',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: AppColors.textMuted(context)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Set up a daily plan from your tiffin vendor to track meal deliveries.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSubtle(context), fontSize: 11),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => _showAddPlanModal(context),
                            icon: const Icon(Icons.add),
                            label: const Text('CREATE TIFFIN PLAN'),
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
                      onEdit: () => _showAddPlanModal(context, planToEdit: item.plan),
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
        label: const Text('ADD PLAN'),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) return 'TODAY';
    if (itemDate == today.subtract(const Duration(days: 1))) return 'YESTERDAY';
    if (itemDate == today.add(const Duration(days: 1))) return 'TOMORROW';
    return DateFormat('d MMM').format(date).toUpperCase();
  }

  void _showAddPlanModal(BuildContext context, {TiffinPlan? planToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => _AddOrEditTiffinPlanSheet(planToEdit: planToEdit),
    );
  }

  void _showMonthCalendarModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (ctx) => const _TiffinMonthlyCalendarSheet(),
    );
  }
}

class _TiffinMonthlyCard extends StatelessWidget {
  final TiffinMonthlySummary summary;
  final VoidCallback onOpenCalendar;

  const _TiffinMonthlyCard({
    required this.summary,
    required this.onOpenCalendar,
  });

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
                            color: AppColors.textMuted(context),
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
                InkWell(
                  onTap: onOpenCalendar,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatusMetric(
                  label: 'RECEIVED',
                  value: '${summary.totalReceived}',
                  color: AppColors.tiffinReceived(context),
                ),
                _StatusMetric(
                  label: 'SKIPPED',
                  value: '${summary.totalSkipped}',
                  color: AppColors.tertiary,
                ),
                _StatusMetric(
                  label: 'PENDING',
                  value: '${summary.totalPending}',
                  color: AppColors.warning,
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
              ?.copyWith(color: const Color(0xFF777777), letterSpacing: 0.8),
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

          final isDark = Theme.of(context).brightness == Brightness.dark;

          return InkWell(
            borderRadius: BorderRadius.circular(2),
            onTap: () => onSelectDate(day),
            child: Container(
              width: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.paperWhite : AppColors.markerBlack)
                    : AppColors.surface(context),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.paperWhite : AppColors.markerBlack)
                      : AppColors.border(context),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(day).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w400,
                      color: isSelected
                          ? (isDark ? AppColors.markerBlack : AppColors.paperWhite)
                          : AppColors.textMuted(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(day),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (isDark ? AppColors.markerBlack : AppColors.paperWhite)
                          : AppColors.text(context),
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
  final VoidCallback onEdit;

  const _TiffinMealCard({
    required this.plan,
    required this.log,
    required this.dateStr,
    required this.onEdit,
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
        statusColor = AppColors.tiffinReceived(context);
        statusText = 'RECEIVED (AUTO-LOGGED ₹${plan.pricePerTiffinPaise ~/ 100})';
        statusIcon = Icons.check_circle;
        break;
      case 'skipped':
        statusColor = AppColors.tertiary;
        statusText = 'SKIPPED (NO CHARGE)';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppColors.warning;
        statusText = 'PENDING CONFIRMATION';
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
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Icon(
                    plan.mealType == 'dinner'
                        ? Icons.nightlife
                        : plan.mealType == 'lunch'
                            ? Icons.lunch_dining
                            : Icons.breakfast_dining,
                    color: AppColors.styleOf(context) == AppThemeStyle.neobrutalism
                        ? (plan.mealType == 'dinner'
                            ? AppColors.neoPurple
                            : AppColors.neoOrange)
                        : AppColors.kraftBrown,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${plan.mealType.toUpperCase()} // ${plan.providerName.toUpperCase()}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'DAILY @ ${plan.reminderTime} • ${Money.format(plan.pricePerTiffinPaise, showDecimal: false)}/MEAL',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted(context)),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 20, color: AppColors.textMuted(context)),
                  onSelected: (val) async {
                    if (val == 'edit') {
                      onEdit();
                    } else if (val == 'delete') {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('DELETE TIFFIN PLAN'),
                          content: Text('Delete plan for "${plan.providerName}" (${plan.mealType})?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('CANCEL'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: AppColors.tertiary),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('DELETE'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await repo.deletePlan(plan.id);
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Plan'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.tertiary),
                          SizedBox(width: 8),
                          Text('Delete Plan', style: TextStyle(color: AppColors.tertiary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            if (status == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await repo.markSkipped(planId: plan.id, date: dateStr);
                      },
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('SKIP'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.tiffinReceived(context),
                        foregroundColor: (Theme.of(context).brightness == Brightness.dark &&
                                AppColors.styleOf(context) == AppThemeStyle.neobrutalism)
                            ? const Color(0xFF000000)
                            : const Color(0xFFFFFFFF),
                      ),
                      onPressed: () async {
                        await repo.markReceived(planId: plan.id, date: dateStr);
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('RECEIVED'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: status == 'received'
                            ? AppColors.tertiaryOf(context)
                            : AppColors.tiffinReceived(context),
                      ),
                      onPressed: () async {
                        if (status == 'received') {
                          await repo.markSkipped(planId: plan.id, date: dateStr);
                        } else {
                          await repo.markReceived(planId: plan.id, date: dateStr);
                        }
                      },
                      icon: Icon(status == 'received' ? Icons.close : Icons.check, size: 16),
                      label: Text(status == 'received' ? 'SWITCH TO SKIPPED' : 'SWITCH TO RECEIVED'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddOrEditTiffinPlanSheet extends ConsumerStatefulWidget {
  final TiffinPlan? planToEdit;

  const _AddOrEditTiffinPlanSheet({this.planToEdit});

  @override
  ConsumerState<_AddOrEditTiffinPlanSheet> createState() =>
      _AddOrEditTiffinPlanSheetState();
}

class _AddOrEditTiffinPlanSheetState
    extends ConsumerState<_AddOrEditTiffinPlanSheet> {
  late final TextEditingController _providerController;
  late final TextEditingController _priceController;
  late String _mealType;
  late TimeOfDay _reminderTime;

  @override
  void initState() {
    super.initState();
    final p = widget.planToEdit;
    _providerController = TextEditingController(text: p?.providerName ?? '');
    _priceController = TextEditingController(
      text: p != null ? '${p.pricePerTiffinPaise ~/ 100}' : '80',
    );
    _mealType = p?.mealType ?? 'lunch';

    if (p != null) {
      final parts = p.reminderTime.split(':');
      final h = int.tryParse(parts[0]) ?? 12;
      final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      _reminderTime = TimeOfDay(hour: h, minute: m);
    } else {
      _reminderTime = const TimeOfDay(hour: 12, minute: 30);
    }
  }

  @override
  void dispose() {
    _providerController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.planToEdit != null;

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
              Text(
                isEditing ? 'EDIT TIFFIN PLAN' : 'NEW TIFFIN PLAN',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
              labelText: 'VENDOR / PROVIDER NAME',
              hintText: 'e.g. Sai Tiffin Service',
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _mealType,
                  decoration: const InputDecoration(labelText: 'MEAL TYPE'),
                  items: const [
                    DropdownMenuItem(value: 'breakfast', child: Text('BREAKFAST')),
                    DropdownMenuItem(value: 'lunch', child: Text('LUNCH')),
                    DropdownMenuItem(value: 'dinner', child: Text('DINNER')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _mealType = val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'PRICE / MEAL (₹)',
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
            title: const Text('DAILY REMINDER TIME'),
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

                if (isEditing) {
                  await repo.updatePlan(
                    id: widget.planToEdit!.id,
                    providerName: name,
                    mealType: _mealType,
                    pricePerTiffinPaise: pricePaise,
                    activeWeekdaysMask: widget.planToEdit!.activeWeekdaysMask,
                    reminderTime: timeStr,
                  );
                } else {
                  await repo.createPlan(
                    providerName: name,
                    mealType: _mealType,
                    pricePerTiffinPaise: pricePaise,
                    activeWeekdaysMask: 127, // All days
                    reminderTime: timeStr,
                    startDate: todayStr,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(isEditing ? 'UPDATE PLAN' : 'CREATE PLAN'),
            ),
          ),

          if (isEditing) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.tertiary,
                  side: const BorderSide(color: AppColors.tertiary),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('DELETE PLAN'),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('DELETE TIFFIN PLAN'),
                      content: Text(
                          'Delete plan for "${widget.planToEdit!.providerName}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('CANCEL'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.tertiary),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('DELETE'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final repo = ref.read(tiffinRepositoryProvider);
                    await repo.deletePlan(widget.planToEdit!.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TiffinMonthlyCalendarSheet extends ConsumerStatefulWidget {
  const _TiffinMonthlyCalendarSheet();

  @override
  ConsumerState<_TiffinMonthlyCalendarSheet> createState() =>
      _TiffinMonthlyCalendarSheetState();
}

class _TiffinMonthlyCalendarSheetState
    extends ConsumerState<_TiffinMonthlyCalendarSheet> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final selectedStr = ref.read(tiffinSelectedDateProvider);
    final dt = DateTime.tryParse(selectedStr) ?? DateTime.now();
    _displayedMonth = DateTime(dt.year, dt.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthPrefix = DateFormat('yyyy-MM').format(_displayedMonth);
    final logsAsync =
        ref.watch(tiffinLogsForSpecificMonthProvider(monthPrefix));
    final plansAsync = ref.watch(activeTiffinPlansProvider);
    final selectedDateStr = ref.watch(tiffinSelectedDateProvider);
    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);

    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1; // Mon=1 -> 0 leading empty

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _prevMonth,
              ),
              Text(
                DateFormat('MMMM yyyy').format(_displayedMonth).toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextMonth,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar Grid
          logsAsync.when(
            data: (logs) {
              final plans = plansAsync.value ?? [];
              final logsByDate = <String, List<TiffinLog>>{};
              for (final l in logs) {
                logsByDate.putIfAbsent(l.date, () => []).add(l);
              }

              final receivedColor = AppColors.tiffinReceived(context);
              final skippedColor = AppColors.tertiaryOf(context);
              final pendingColor = AppColors.warningOf(context);

              int monthReceived = 0;
              int monthSkipped = 0;
              int monthPending = 0;

              for (int day = 1; day <= daysInMonth; day++) {
                final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
                final dateStr = DateFormat('yyyy-MM-dd').format(date);
                final dayLogs = logsByDate[dateStr] ?? [];
                if (dayLogs.any((l) => l.status == 'received')) monthReceived++;
                if (dayLogs.any((l) => l.status == 'skipped')) monthSkipped++;
                if (!date.isAfter(DateTime(now.year, now.month, now.day))) {
                  final weekdayMask = 1 << (date.weekday - 1);
                  final applicable = plans.where((p) =>
                      (p.activeWeekdaysMask & weekdayMask) != 0 &&
                      p.startDate.compareTo(dateStr) <= 0);
                  if (applicable.isNotEmpty) {
                    for (final p in applicable) {
                      final log = dayLogs.firstWhere(
                        (l) => l.planId == p.id,
                        orElse: () => TiffinLog(
                          id: '',
                          planId: p.id,
                          date: dateStr,
                          status: 'pending',
                        ),
                      );
                      if (log.status == 'pending') {
                        monthPending++;
                        break;
                      }
                    }
                  }
                }
              }

              return Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: leadingEmpty + daysInMonth,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (ctx, index) {
                      if (index < leadingEmpty) {
                        return const SizedBox.shrink();
                      }
                      final day = index - leadingEmpty + 1;
                      final date = DateTime(
                          _displayedMonth.year, _displayedMonth.month, day);
                      final dateStr = DateFormat('yyyy-MM-dd').format(date);
                      final isSelected = (dateStr == selectedDateStr);
                      final isToday = (dateStr == todayStr);

                      final dayLogs = logsByDate[dateStr] ?? [];
                      final hasReceived =
                          dayLogs.any((l) => l.status == 'received');
                      final hasSkipped =
                          dayLogs.any((l) => l.status == 'skipped');

                      // Pending check: if date is today or past, and active plan applies, but neither received nor skipped
                      bool hasPending = false;
                      if (!date.isAfter(DateTime(now.year, now.month, now.day))) {
                        final weekdayMask = 1 << (date.weekday - 1);
                        final applicable = plans.where((p) =>
                            (p.activeWeekdaysMask & weekdayMask) != 0 &&
                            p.startDate.compareTo(dateStr) <= 0);
                        if (applicable.isNotEmpty) {
                          for (final p in applicable) {
                            final log = dayLogs.firstWhere(
                              (l) => l.planId == p.id,
                              orElse: () => TiffinLog(
                                id: '',
                                planId: p.id,
                                date: dateStr,
                                status: 'pending',
                              ),
                            );
                            if (log.status == 'pending') {
                              hasPending = true;
                              break;
                            }
                          }
                        }
                      }

                      final isNeo = AppColors.styleOf(context) == AppThemeStyle.neobrutalism;
                      final isDark = Theme.of(context).brightness == Brightness.dark;

                      BoxDecoration? highlightDecoration;
                      Color dayTextColor;

                      if (hasReceived && hasSkipped) {
                        // Received + Skipped dual tone circular highlight
                        highlightDecoration = BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [receivedColor, skippedColor],
                            stops: const [0.5, 0.5],
                          ),
                          border: Border.all(
                            color: isNeo ? const Color(0xFF000000) : AppColors.border(context),
                            width: isNeo ? 1.5 : 1.0,
                          ),
                        );
                        dayTextColor = Colors.white;
                      } else if (hasReceived) {
                        // Solid green circular highlight
                        highlightDecoration = BoxDecoration(
                          shape: BoxShape.circle,
                          color: receivedColor,
                          border: Border.all(
                            color: isNeo ? const Color(0xFF000000) : receivedColor,
                            width: isNeo ? 1.5 : 1.0,
                          ),
                          boxShadow: isNeo
                              ? const [
                                  BoxShadow(
                                    color: Color(0xFF000000),
                                    offset: Offset(1.5, 1.5),
                                    blurRadius: 0,
                                  ),
                                ]
                              : null,
                        );
                        dayTextColor = (isDark && isNeo)
                            ? const Color(0xFF000000)
                            : Colors.white;
                      } else if (hasSkipped) {
                        // Solid skipped circular highlight
                        highlightDecoration = BoxDecoration(
                          shape: BoxShape.circle,
                          color: skippedColor,
                          border: Border.all(
                            color: isNeo ? const Color(0xFF000000) : skippedColor,
                            width: isNeo ? 1.5 : 1.0,
                          ),
                          boxShadow: isNeo
                              ? const [
                                  BoxShadow(
                                    color: Color(0xFF000000),
                                    offset: Offset(1.5, 1.5),
                                    blurRadius: 0,
                                  ),
                                ]
                              : null,
                        );
                        dayTextColor = Colors.white;
                      } else if (hasPending) {
                        // Pending circular highlight (tinted surface + amber border)
                        highlightDecoration = BoxDecoration(
                          shape: BoxShape.circle,
                          color: pendingColor.withValues(alpha: 0.22),
                          border: Border.all(
                            color: pendingColor,
                            width: isNeo ? 1.5 : 1.2,
                          ),
                        );
                        dayTextColor = isDark ? pendingColor : const Color(0xFF854D0E);
                      } else {
                        // Unmarked date
                        highlightDecoration = isToday
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surface(context),
                                border: Border.all(
                                  color: AppColors.border(context),
                                  width: 1.0,
                                ),
                              )
                            : null;
                        dayTextColor = AppColors.text(context);
                      }

                      return InkWell(
                        onTap: () {
                          ref.read(tiffinSelectedDateProvider.notifier).state =
                              dateStr;
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: isNeo
                                          ? AppColors.neoYellow
                                          : AppColors.primaryOf(context),
                                      width: 2.5,
                                    )
                                  : null,
                            ),
                            padding: isSelected
                                ? const EdgeInsets.all(2)
                                : EdgeInsets.zero,
                            child: Container(
                              decoration: highlightDecoration ??
                                  (isSelected
                                      ? BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primaryOf(context)
                                              .withValues(alpha: 0.15),
                                        )
                                      : null),
                              alignment: Alignment.center,
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: (highlightDecoration != null ||
                                          isSelected ||
                                          isToday)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: (isSelected && highlightDecoration == null)
                                      ? AppColors.primaryOf(context)
                                      : dayTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Legend row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CalendarLegendItem(
                        color: receivedColor,
                        label: 'Received',
                        count: monthReceived,
                      ),
                      _CalendarLegendItem(
                        color: skippedColor,
                        label: 'Skipped',
                        count: monthSkipped,
                      ),
                      _CalendarLegendItem(
                        color: pendingColor,
                        label: 'Pending',
                        count: monthPending,
                      ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(child: Text('Error loading calendar: $e')),
          ),
        ],
      ),
    );
  }
}

class _CalendarLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _CalendarLegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border(context),
              width: 1.0,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted(context),
          ),
        ),
      ],
    );
  }
}
