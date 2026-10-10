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
        title: const Text('ADD TASK'),
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
              style: Theme.of(context).textTheme.titleMedium,
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
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AUTOMATION DETECTED',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'When completed, automatically log ₹${((_detectedIntent!.payload['amountPaise'] as int?) ?? 0) ~/ 100} in ${_detectedIntent!.payload['categoryHint']} category.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: const Color(0xFF777777)),
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
                labelText: 'NOTES & DETAILS (OPTIONAL)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Priority Selector
            Text('PRIORITY', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _PriorityOption(
                  label: 'HIGH',
                  color: AppColors.tertiary,
                  isSelected: _priority == 0,
                  onTap: () => setState(() => _priority = 0),
                ),
                const SizedBox(width: 8),
                _PriorityOption(
                  label: 'MEDIUM',
                  color: AppColors.warning,
                  isSelected: _priority == 1,
                  onTap: () => setState(() => _priority = 1),
                ),
                const SizedBox(width: 8),
                _PriorityOption(
                  label: 'LOW',
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
                    title: const Text('DUE DATE'),
                    subtitle: Text(
                      _dueDate != null
                          ? DateFormat('d MMM yyyy').format(_dueDate!).toUpperCase()
                          : 'NOT SET',
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
                      title: const Text('DUE TIME'),
                      subtitle: Text(
                        _dueTime != null
                            ? _dueTime!.format(context).toUpperCase()
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
                labelText: 'REPEAT',
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('DOES NOT REPEAT')),
                DropdownMenuItem(value: 'daily', child: Text('EVERY DAY')),
                DropdownMenuItem(value: 'weekly', child: Text('EVERY WEEK')),
                DropdownMenuItem(value: 'monthly', child: Text('EVERY MONTH')),
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
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.markerBlack),
                      )
                    : const Text(
                        'SAVE TASK',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
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
        borderRadius: BorderRadius.circular(2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.15)
                : const Color(0xFF1F1F1F),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: isSelected ? color : const Color(0xFF3A3A3A),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : const Color(0xFF777777),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
