/// Budget Planner screen with overall limit progress, safe-to-spend metric,
/// category breakdowns, FL Chart spending visualization, and recurring bills.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/core/money.dart';
import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/features/expenses/domain/expense_providers.dart';
import 'package:bachelor_buddy/features/budget/domain/budget_providers.dart';
import 'package:bachelor_buddy/features/budget/data/budget_repository.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(budgetOverviewProvider);
    final recurringsAsync = ref.watch(recurringExpensesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget & Recurring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showSetOverallBudgetModal(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Budget Card
            overviewAsync.when(
              data: (overview) => _OverallBudgetCard(
                overview: overview,
                onEdit: () => _showSetOverallBudgetModal(context, ref),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
            const SizedBox(height: 20),

            // Spending Distribution Chart
            overviewAsync.when(
              data: (overview) {
                final activeStatuses = overview.categoryStatuses
                    .where((c) => c.spentPaise > 0)
                    .toList();
                if (activeStatuses.isEmpty) return const SizedBox.shrink();
                return _SpendingPieChartCard(statuses: activeStatuses);
              },
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Category Budgets Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Category Budgets',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),

            // Category List
            overviewAsync.when(
              data: (overview) => _CategoryBudgetList(
                statuses: overview.categoryStatuses,
                month: selectedMonth,
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Recurring Bills Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recurring Expenses & Rent',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddRecurringModal(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Bill'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            recurringsAsync.when(
              data: (recurrings) => _RecurringExpensesList(items: recurrings),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  void _showSetOverallBudgetModal(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final month = ref.read(selectedMonthProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Overall Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Budget Limit (₹)',
            prefixText: '₹ ',
            hintText: 'e.g. 25000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amountPaise = Money.parse(controller.text);
              if (amountPaise > 0) {
                final repo = ref.read(budgetRepositoryProvider);
                await repo.setBudget(month: month, limitPaise: amountPaise);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddRecurringModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _AddRecurringExpenseSheet(),
    );
  }
}

class _OverallBudgetCard extends StatelessWidget {
  final MonthBudgetOverview overview;
  final VoidCallback onEdit;

  const _OverallBudgetCard({
    required this.overview,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasLimit = overview.limitPaise > 0;
    final pct = (overview.percentage * 100).clamp(0, 100).toInt();

    Color progressColor;
    if (overview.percentage > 0.9) {
      progressColor = AppColors.tertiary; // Red
    } else if (overview.percentage > 0.75) {
      progressColor = Colors.amber; // Warning
    } else {
      progressColor = AppColors.secondary; // Green
    }

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL MONTHLY BUDGET',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            color: Colors.white54,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasLimit
                          ? Money.format(overview.limitPaise, showDecimal: false)
                          : 'Not set',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: hasLimit ? overview.percentage.clamp(0.0, 1.0) : 0.0,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${Money.format(overview.spentPaise, showDecimal: false)} ($pct%)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
                Text(
                  hasLimit
                      ? 'Left: ${Money.format(overview.remainingPaise, showDecimal: false)}'
                      : '',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: overview.remainingPaise < 0
                        ? AppColors.tertiary
                        : AppColors.secondary,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            // Safe to spend daily
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_outlined,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Safe-to-Spend per day',
                          style: TextStyle(fontSize: 11, color: Colors.white60),
                        ),
                        Text(
                          hasLimit
                              ? '${Money.format(overview.safeToSpendPerDayPaise, showDecimal: false)} / day'
                              : 'Set a monthly budget to calculate',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${overview.remainingDays} days left',
                    style: const TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingPieChartCard extends StatelessWidget {
  final List<CategoryBudgetStatus> statuses;

  const _SpendingPieChartCard({required this.statuses});

  @override
  Widget build(BuildContext context) {
    final totalSpent = statuses.fold<int>(0, (a, b) => a + b.spentPaise);
    if (totalSpent <= 0) return const SizedBox.shrink();

    final palette = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      Colors.orange,
      Colors.purpleAccent,
      Colors.cyan,
      Colors.lime,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Distribution',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 36,
                  sections: statuses.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final color = palette[idx % palette.length];
                    final pct = (item.spentPaise / totalSpent) * 100;

                    return PieChartSectionData(
                      color: color,
                      value: item.spentPaise.toDouble(),
                      title: pct >= 8 ? '${pct.toInt()}%' : '',
                      radius: 40,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: statuses.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final color = palette[idx % palette.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.category.name}: ${Money.format(item.spentPaise, showDecimal: false)}',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
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

class _CategoryBudgetList extends ConsumerWidget {
  final List<CategoryBudgetStatus> statuses;
  final String month;

  const _CategoryBudgetList({required this.statuses, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final item = statuses[index];
        final hasLimit = item.limitPaise != null && item.limitPaise! > 0;
        final pct = hasLimit ? (item.percentage * 100).toInt() : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => _editCategoryBudget(context, ref, item),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.category.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  Money.format(item.spentPaise, showDecimal: false),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                if (hasLimit) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item.percentage.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        item.percentage > 1.0
                            ? AppColors.tertiary
                            : AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Limit: ${Money.format(item.limitPaise!, showDecimal: false)} ($pct%)',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white54),
                      ),
                      Text(
                        'Tap to edit',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.primary),
                      ),
                    ],
                  ),
                ] else ...[
                  const Text(
                    'No budget limit set • Tap to set limit',
                    style: TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _editCategoryBudget(
      BuildContext context, WidgetRef ref, CategoryBudgetStatus item) {
    final controller = TextEditingController(
      text: item.limitPaise != null ? '${item.limitPaise! ~/ 100}' : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Budget for ${item.category.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Monthly Limit (₹)',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amountPaise = Money.parse(controller.text);
              final repo = ref.read(budgetRepositoryProvider);
              await repo.setBudget(
                month: month,
                categoryId: item.category.id,
                limitPaise: amountPaise,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _RecurringExpensesList extends ConsumerWidget {
  final List<RecurringExpense> items;

  const _RecurringExpensesList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(
          'No recurring bills added. Add rent, subscriptions, or WiFi bills to auto-generate them every month.',
          style: TextStyle(fontSize: 12, color: Colors.white38),
        ),
      );
    }

    final repo = ref.read(budgetRepositoryProvider);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final rec = items[index];

        return Dismissible(
          key: ValueKey(rec.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppColors.tertiary.withValues(alpha: 0.2),
            child: const Icon(Icons.delete_outline, color: AppColors.tertiary),
          ),
          onDismissed: (_) async {
            await repo.deleteRecurringExpense(rec.id);
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.repeat, color: AppColors.primary, size: 20),
              ),
              title: Text(rec.title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Due on day ${rec.dayOfMonth} of each month',
                style: const TextStyle(fontSize: 11, color: Colors.white54),
              ),
              trailing: Text(
                Money.format(rec.amountPaise, showDecimal: false),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddRecurringExpenseSheet extends ConsumerStatefulWidget {
  const _AddRecurringExpenseSheet();

  @override
  ConsumerState<_AddRecurringExpenseSheet> createState() =>
      _AddRecurringExpenseSheetState();
}

class _AddRecurringExpenseSheetState
    extends ConsumerState<_AddRecurringExpenseSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  int _dayOfMonth = 1;
  String? _selectedCategoryId;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider('expense'));

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
              Text('Add Recurring Bill / Rent',
                  style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Bill Title',
              hintText: 'e.g. House Rent, WiFi, Netflix',
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    prefixText: '₹ ',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _dayOfMonth,
                  decoration: const InputDecoration(labelText: 'Day of Month'),
                  items: List.generate(31, (i) => i + 1).map((d) {
                    return DropdownMenuItem(value: d, child: Text('Day $d'));
                  }).toList(),
                  onChanged: (val) => setState(() => _dayOfMonth = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          categoriesAsync.when(
            data: (cats) {
              if (_selectedCategoryId == null && cats.isNotEmpty) {
                _selectedCategoryId = cats.first.id;
              }
              return DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: cats.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategoryId = val),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final amountPaise = Money.parse(_amountController.text);
                if (title.isEmpty ||
                    amountPaise <= 0 ||
                    _selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill all required fields')),
                  );
                  return;
                }

                final repo = ref.read(budgetRepositoryProvider);
                await repo.addRecurringExpense(
                  title: title,
                  amountPaise: amountPaise,
                  categoryId: _selectedCategoryId!,
                  dayOfMonth: _dayOfMonth,
                );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Add Recurring Bill'),
            ),
          ),
        ],
      ),
    );
  }
}
