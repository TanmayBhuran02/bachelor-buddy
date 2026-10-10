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
      key: const ValueKey('budget_scaffold'),
      appBar: AppBar(
        title: const Text('BUDGET & RECURRING'),
        actions: [
          IconButton(
            key: const ValueKey('budget_edit_button'),
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
                'CATEGORY BUDGETS',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(letterSpacing: 0.8),
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
                    'RECURRING EXPENSES & RENT',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(letterSpacing: 0.8),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddRecurringModal(context, ref),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('ADD BILL'),
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
        title: const Text('SET MONTHLY BUDGET'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'BUDGET LIMIT (₹)',
            prefixText: '₹ ',
            hintText: 'e.g. 25000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
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
            child: const Text('SAVE'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
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
      progressColor = AppColors.warning; // Amber
    } else {
      progressColor = AppColors.secondary; // Teal
    }

    return Card(
      key: const ValueKey('overall_budget_card'),
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
                            color: const Color(0xFF777777),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasLimit
                          ? Money.format(overview.limitPaise, showDecimal: false)
                          : 'NOT SET',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.paperWhite,
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

            // Progress bar (square corners)
            LinearProgressIndicator(
              value: hasLimit ? overview.percentage.clamp(0.0, 1.0) : 0.0,
              minHeight: 8,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'SPENT: ${Money.format(overview.spentPaise, showDecimal: false)} ($pct%)',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: const Color(0xFF888888)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    hasLimit
                        ? 'LEFT: ${Money.format(overview.remainingPaise, showDecimal: false)}'
                        : '',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: overview.remainingPaise < 0
                          ? AppColors.tertiary
                          : AppColors.secondary,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 28),

            // Safe to spend daily
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_outlined,
                      color: AppColors.kraftBrown, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SAFE-TO-SPEND / DAY',
                          style: TextStyle(fontSize: 10, color: Color(0xFF777777), letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasLimit
                              ? '${Money.format(overview.safeToSpendPerDayPaise, showDecimal: false)} / DAY'
                              : 'Set a monthly budget to calculate',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.paperWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${overview.remainingDays} DAYS LEFT',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF555555), letterSpacing: 0.5),
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
      AppColors.kraftBrown,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.warning,
      const Color(0xFF5E81AC),
      const Color(0xFF88C0D0),
      const Color(0xFFB48EAD),
    ];

    return Card(
      key: const ValueKey('spending_pie_chart_card'),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SPENDING DISTRIBUTION',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(letterSpacing: 0.8)),
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
                        color: AppColors.paperWhite,
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
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.category.name.toUpperCase()}: ${Money.format(item.spentPaise, showDecimal: false)}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF888888), letterSpacing: 0.5),
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
                Text(item.category.name.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                  LinearProgressIndicator(
                    value: item.percentage.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: const Color(0xFF2A2A2A),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.percentage > 1.0
                          ? AppColors.tertiary
                          : AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LIMIT: ${Money.format(item.limitPaise!, showDecimal: false)} ($pct%)',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF777777), letterSpacing: 0.5),
                      ),
                      const Text(
                        'TAP TO EDIT →',
                        style: TextStyle(
                            fontSize: 9, color: Color(0xFF888888), letterSpacing: 0.8),
                      ),
                    ],
                  ),
                ] else ...[
                  const Text(
                    'No budget limit set • Tap to set limit',
                    style: TextStyle(fontSize: 11, color: Color(0xFF555555)),
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
        title: Text('BUDGET FOR ${item.category.name.toUpperCase()}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'MONTHLY LIMIT (₹)',
            prefixText: '₹ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
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
            child: const Text('SAVE'),
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
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(
          'No recurring bills added. Add rent, subscriptions, or WiFi bills to auto-generate them every month.',
          style: TextStyle(fontSize: 11, color: Color(0xFF555555)),
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
            key: ValueKey('recurring_expense_${rec.id}'),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: const Icon(Icons.repeat, color: AppColors.kraftBrown, size: 20),
              ),
              title: Text(rec.title.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text(
                'DUE ON DAY ${rec.dayOfMonth} OF MONTH',
                style: const TextStyle(fontSize: 10, color: Color(0xFF777777), letterSpacing: 0.5),
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
              Text('ADD RECURRING BILL / RENT',
                  style: Theme.of(context).textTheme.titleMedium),
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
              labelText: 'BILL TITLE',
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
                    labelText: 'AMOUNT (₹)',
                    prefixText: '₹ ',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _dayOfMonth,
                  decoration: const InputDecoration(labelText: 'DAY OF MONTH'),
                  items: List.generate(31, (i) => i + 1).map((d) {
                    return DropdownMenuItem(value: d, child: Text('DAY $d'));
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
                decoration: const InputDecoration(labelText: 'CATEGORY'),
                items: cats.map((c) {
                  return DropdownMenuItem(value: c.id, child: Text(c.name.toUpperCase()));
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
              child: const Text('ADD RECURRING BILL'),
            ),
          ),
        ],
      ),
    );
  }
}
