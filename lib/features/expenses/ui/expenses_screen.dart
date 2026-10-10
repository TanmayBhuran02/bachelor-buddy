/// Expenses list screen with grouped-by-day transactions, month selector,
/// category filtering, and real reactive data.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/core/money.dart';
import 'package:bachelor_buddy/features/expenses/data/expense_repository.dart';
import 'package:bachelor_buddy/features/expenses/domain/expense_providers.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _iconForCategory(String iconKey) {
    return switch (iconKey) {
      'restaurant' => Icons.restaurant,
      'lunch_dining' => Icons.lunch_dining,
      'home' => Icons.home,
      'directions_car' => Icons.directions_car,
      'shopping_cart' => Icons.shopping_cart,
      'bolt' => Icons.bolt,
      'phone_android' => Icons.phone_android,
      'movie' => Icons.movie,
      'local_hospital' => Icons.local_hospital,
      'shopping_bag' => Icons.shopping_bag,
      'account_balance_wallet' => Icons.account_balance_wallet,
      'work' => Icons.work,
      'attach_money' => Icons.attach_money,
      _ => Icons.category,
    };
  }

  Color _colorForCategory(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final totalsAsync = ref.watch(monthlyTotalsStreamProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search note or category...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  ref.read(expenseSearchQueryProvider.notifier).state = query;
                },
              )
            : const Text('EXPENSES'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(expenseSearchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showCategoryFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month selector
          _MonthSelector(
            currentMonthStr: selectedMonth,
            onMonthChanged: (newMonth) {
              ref.read(selectedMonthProvider.notifier).state = newMonth;
            },
          ),
          const SizedBox(height: 8),

          // Monthly summary card
          totalsAsync.when(
            data: (totals) => _MonthlySummary(totals: totals),
            loading: () => const LinearProgressIndicator(),
            error: (e, s) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),

          // Active category filter chip (if any)
          Consumer(builder: (context, ref, _) {
            final activeFilter = ref.watch(selectedCategoryFilterProvider);
            if (activeFilter == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Chip(
                    label: const Text('FILTERED'),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      ref.read(selectedCategoryFilterProvider.notifier).state =
                          null;
                    },
                  ),
                ],
              ),
            );
          }),

          // Transaction list
          Expanded(
            child: transactionsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 48, color: const Color(0xFF3A3A3A)),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions for this month',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: const Color(0xFF888888)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to record an expense or income',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: const Color(0xFF555555)),
                        ),
                      ],
                    ),
                  );
                }

                // Group by date
                final grouped = <String, List<TransactionWithCategory>>{};
                for (final item in list) {
                  grouped.putIfAbsent(item.transaction.date, () => []).add(item);
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, index) {
                    final dateKey = grouped.keys.elementAt(index);
                    final dayItems = grouped[dateKey]!;
                    final dayTotal = dayItems.fold<int>(
                      0,
                      (acc, item) => item.transaction.type == 'expense'
                          ? acc + item.transaction.amountPaise
                          : acc,
                    );

                    final dateParsed = DateTime.tryParse(dateKey);
                    final formattedDate = dateParsed != null
                        ? _formatDateHeader(dateParsed)
                        : dateKey;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DateHeader(date: formattedDate, total: dayTotal),
                        ...dayItems.map((item) {
                          final tx = item.transaction;
                          final cat = item.category;
                          final isAuto = tx.source != 'manual';

                          return Dismissible(
                            key: ValueKey(tx.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: AppColors.tertiary.withValues(alpha: 0.15),
                              child: const Icon(Icons.delete_outline,
                                  color: AppColors.tertiary),
                            ),
                            onDismissed: (_) async {
                              final repo = ref.read(expenseRepositoryProvider);
                              await repo.deleteTransaction(tx.id);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${tx.note.isEmpty ? cat.name : tx.note} deleted'),
                                    action: SnackBarAction(
                                      label: 'UNDO',
                                      onPressed: () async {
                                        await repo.addTransaction(
                                          amountPaise: tx.amountPaise,
                                          type: tx.type,
                                          categoryId: tx.categoryId,
                                          note: tx.note,
                                          date: tx.date,
                                          source: tx.source,
                                          sourceRefId: tx.sourceRefId,
                                          isShared: tx.isShared,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                            child: ListTile(
                              onTap: () => context.push('/expenses/edit/${tx.id}'),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _colorForCategory(cat.colorHex)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Icon(
                                  _iconForCategory(cat.iconKey),
                                  color: _colorForCategory(cat.colorHex),
                                  size: 20,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      tx.note.isEmpty ? cat.name : tx.note,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isAuto) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        '// AUTO',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontSize: 9,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                    ),
                                  ],
                                  if (tx.isShared) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        ':: SHARED',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.secondary,
                                              fontSize: 9,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Container(
                                margin: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF222222),
                                        borderRadius:
                                            BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        cat.name.toUpperCase(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                                color: const Color(0xFF777777),
                                                letterSpacing: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Text(
                                '${tx.type == "expense" ? "-" : "+"}${Money.format(tx.amountPaise, showDecimal: false)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: tx.type == 'expense'
                                          ? AppColors.tertiary
                                          : AppColors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
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
        onPressed: () => context.push('/expenses/new'),
        icon: const Icon(Icons.add),
        label: const Text('ADD EXPENSE'),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'TODAY, ${DateFormat('d MMM').format(date).toUpperCase()}';
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return 'YESTERDAY, ${DateFormat('d MMM').format(date).toUpperCase()}';
    } else {
      return DateFormat('EEEE, d MMM').format(date).toUpperCase();
    }
  }

  void _showCategoryFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer(builder: (context, ref, _) {
          final categoriesAsync = ref.watch(categoriesStreamProvider(null));
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('FILTER BY CATEGORY',
                        style: Theme.of(context).textTheme.titleMedium),
                    TextButton(
                      onPressed: () {
                        ref
                            .read(selectedCategoryFilterProvider.notifier)
                            .state = null;
                        Navigator.pop(context);
                      },
                      child: const Text('RESET'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                categoriesAsync.when(
                  data: (cats) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: cats.map((c) {
                      final isSelected =
                          ref.watch(selectedCategoryFilterProvider) == c.id;
                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(c.name.toUpperCase()),
                        onSelected: (selected) {
                          ref
                              .read(selectedCategoryFilterProvider.notifier)
                              .state = selected ? c.id : null;
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final String currentMonthStr; // 'YYYY-MM'
  final ValueChanged<String> onMonthChanged;

  const _MonthSelector({
    required this.currentMonthStr,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final parsed = DateFormat('yyyy-MM').parse(currentMonthStr);
    final prevMonth = DateTime(parsed.year, parsed.month - 1);
    final nextMonth = DateTime(parsed.year, parsed.month + 1);

    final months = [prevMonth, parsed, nextMonth];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () {
              onMonthChanged(DateFormat('yyyy-MM').format(prevMonth));
            },
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: months.map((m) {
                final mStr = DateFormat('yyyy-MM').format(m);
                final isActive = mStr == currentMonthStr;
                return Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ChoiceChip(
                      label: Text(
                        DateFormat('MMM yyyy').format(m).toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      selected: isActive,
                      onSelected: (_) => onMonthChanged(mStr),
                      selectedColor: AppColors.paperWhite,
                      labelStyle: TextStyle(
                        color: isActive
                            ? AppColors.markerBlack
                            : const Color(0xFF888888),
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w400,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: () {
              onMonthChanged(DateFormat('yyyy-MM').format(nextMonth));
            },
          ),
        ],
      ),
    );
  }
}

class _MonthlySummary extends StatelessWidget {
  final MonthlyTotals totals;

  const _MonthlySummary({required this.totals});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem('INCOME',
                Money.format(totals.totalIncomePaise, showDecimal: false),
                AppColors.secondary),
            Container(
                width: 1,
                height: 32,
                color: const Color(0xFF3A3A3A)),
            _SummaryItem('EXPENSES',
                Money.format(totals.totalExpensePaise, showDecimal: false),
                AppColors.tertiary),
            Container(
                width: 1,
                height: 32,
                color: const Color(0xFF3A3A3A)),
            _SummaryItem('BALANCE',
                Money.format(totals.balancePaise, showDecimal: false),
                AppColors.paperWhite),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: const Color(0xFF888888), letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String date;
  final int total;

  const _DateHeader({required this.date, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(
                      color: const Color(0xFF888888), letterSpacing: 0.8)),
          Text(Money.format(total, showDecimal: false),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: const Color(0xFF555555))),
        ],
      ),
    );
  }
}
