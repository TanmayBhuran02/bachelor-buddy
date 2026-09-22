/// Add/Edit Expense screen with category selector, quick chips, and shared split.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:bachelor_buddy/core/money.dart';
import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/features/expenses/domain/expense_providers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? expenseId;

  const AddExpenseScreen({super.key, this.expenseId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense'; // 'expense' | 'income'
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isShared = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      _loadExistingExpense();
    }
  }

  Future<void> _loadExistingExpense() async {
    final repo = ref.read(expenseRepositoryProvider);
    final tx = await repo.getTransaction(widget.expenseId!);
    if (tx != null && mounted) {
      setState(() {
        _amountController.text =
            (tx.amountPaise / 100).toStringAsFixed(tx.amountPaise % 100 == 0 ? 0 : 2);
        _noteController.text = tx.note;
        _type = tx.type;
        _selectedCategoryId = tx.categoryId;
        _selectedDate = DateTime.tryParse(tx.date) ?? DateTime.now();
        _isShared = tx.isShared;
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addQuickAmount(int rupees) {
    final current = double.tryParse(_amountController.text.trim()) ?? 0;
    final updated = current + rupees;
    _amountController.text =
        updated.toStringAsFixed(updated.truncateToDouble() == updated ? 0 : 2);
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

  Future<void> _save() async {
    final amountPaise = Money.parse(_amountController.text);
    if (amountPaise <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(expenseRepositoryProvider);
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

      if (widget.expenseId != null) {
        await repo.updateTransaction(
          id: widget.expenseId!,
          amountPaise: amountPaise,
          type: _type,
          categoryId: _selectedCategoryId!,
          note: _noteController.text.trim(),
          date: dateStr,
          isShared: _isShared,
        );
      } else {
        await repo.addTransaction(
          amountPaise: amountPaise,
          type: _type,
          categoryId: _selectedCategoryId!,
          note: _noteController.text.trim(),
          date: dateStr,
          isShared: _isShared,
        );
      }

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider(_type));
    final isEditing = widget.expenseId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type toggle (Expense / Income)
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward, size: 16),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward, size: 16),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (val) {
                setState(() {
                  _type = val.first;
                  _selectedCategoryId = null; // Reset category on type toggle
                });
              },
            ),
            const SizedBox(height: 24),

            // Amount field
            Text('Amount (₹)', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _type == 'expense'
                        ? AppColors.tertiary
                        : AppColors.secondary,
                  ),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _type == 'expense'
                          ? AppColors.tertiary
                          : AppColors.secondary,
                    ),
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 12),

            // Quick add amount chips
            Wrap(
              spacing: 8,
              children: [10, 50, 100, 200, 500].map((val) {
                return ActionChip(
                  label: Text('+$val'),
                  onPressed: () => _addQuickAmount(val),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Category selector
            Text('Category', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Text('No categories available.');
                }
                if (!_isInitialized && _selectedCategoryId == null && categories.isNotEmpty) {
                  _selectedCategoryId = categories.first.id;
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((cat) {
                    final isSelected = _selectedCategoryId == cat.id;
                    final color = _colorForCategory(cat.colorHex);
                    return ChoiceChip(
                      selected: isSelected,
                      avatar: Icon(
                        _iconForCategory(cat.iconKey),
                        size: 16,
                        color: isSelected ? Colors.white : color,
                      ),
                      label: Text(cat.name),
                      selectedColor: color,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategoryId = cat.id);
                        }
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading categories: $err'),
            ),
            const SizedBox(height: 24),

            // Note
            Text('Note / Description',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g. Chai, Groceries at DMart...',
              ),
            ),
            const SizedBox(height: 24),

            // Date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat('EEEE, d MMMM yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),

            // Roommate Split tag
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Split with Roommates'),
              subtitle: const Text('Tag this transaction as a shared expense'),
              value: _isShared,
              onChanged: (val) => setState(() => _isShared = val),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Update Transaction' : 'Save Transaction',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
