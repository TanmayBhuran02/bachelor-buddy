/// Add To-Do screen with real-time intent parser detection chip,
/// priority selector, and recurrence options.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/providers.dart';
import 'package:bachelor_buddy/features/actions/action_intent.dart';
import 'package:bachelor_buddy/features/todo/domain/todo_providers.dart';

class AddTodoScreen extends ConsumerStatefulWidget {
  const AddTodoScreen({super.key});

  @override
  ConsumerState<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends ConsumerState<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _priority = 1; // 0=High, 1=Medium, 2=Low
  String _recurrence = 'none';

  ActionIntent? _detectedIntent;
  bool _includeDetectedAction = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTextChanged);
    _notesController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onTextChanged() async {
    final text = '${_titleController.text} ${_notesController.text}'.trim();
    final parser = ref.read(intentParserProvider);
    final intent = await parser.parse(text);

    if (mounted) {
      setState(() {
        _detectedIntent = intent;
      });
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      int? dueEpoch;
      if (_dueDate != null) {
        final time = _dueTime ?? const TimeOfDay(hour: 12, minute: 0);
        final fullDate = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          time.hour,
          time.minute,
        );
        dueEpoch = fullDate.toUtc().millisecondsSinceEpoch;
      }

      final repo = ref.read(todoRepositoryProvider);
      await repo.addTodo(
        title: title,
        notes: _notesController.text.trim(),
        dueAt: dueEpoch,
        priority: _priority,
        recurrence: _recurrence,
        actionIntent: _includeDetectedAction ? _detectedIntent : null,
      );

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save task: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: const InputDecoration(
                hintText: 'What needs to be done?',
                border: InputBorder.none,
              ),
            ),
            const Divider(height: 24),

            // Live Intent Detection Card
            if (_detectedIntent != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Automation Detected',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'When completed, automatically log ₹${((_detectedIntent!.payload['amountPaise'] as int?) ?? 0) ~/ 100} in ${_detectedIntent!.payload['categoryHint']} category.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _includeDetectedAction,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _includeDetectedAction = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Notes input
            TextField(
              controller: _notesController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes & details (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Priority Selector
            Text('Priority', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _PriorityOption(
                  label: 'High',
                  color: AppColors.tertiary,
                  isSelected: _priority == 0,
                  onTap: () => setState(() => _priority = 0),
                ),
                const SizedBox(width: 8),
                _PriorityOption(
                  label: 'Medium',
                  color: Colors.amber,
                  isSelected: _priority == 1,
                  onTap: () => setState(() => _priority = 1),
                ),
                const SizedBox(width: 8),
                _PriorityOption(
                  label: 'Low',
                  color: AppColors.secondary,
                  isSelected: _priority == 2,
                  onTap: () => setState(() => _priority = 2),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Due Date & Time
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event),
                    title: const Text('Due Date'),
                    subtitle: Text(
                      _dueDate != null
                          ? DateFormat('d MMM yyyy').format(_dueDate!)
                          : 'Not set',
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _dueDate = picked);
                      }
                    },
                  ),
                ),
                if (_dueDate != null)
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: const Text('Due Time'),
                      subtitle: Text(
                        _dueTime != null
                            ? _dueTime!.format(context)
                            : '12:00 PM',
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _dueTime ?? const TimeOfDay(hour: 12, minute: 0),
                        );
                        if (picked != null) {
                          setState(() => _dueTime = picked);
                        }
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Recurrence Dropdown
            DropdownButtonFormField<String>(
              initialValue: _recurrence,
              decoration: const InputDecoration(
                labelText: 'Repeat',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('Does not repeat')),
                DropdownMenuItem(value: 'daily', child: Text('Every day')),
                DropdownMenuItem(value: 'weekly', child: Text('Every week')),
                DropdownMenuItem(value: 'monthly', child: Text('Every month')),
              ],
              onChanged: (val) => setState(() => _recurrence = val!),
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
                    : const Text(
                        'Save Task',
                        style: TextStyle(
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

class _PriorityOption extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : Colors.white12,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
