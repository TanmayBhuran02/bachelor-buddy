/// Action handler that creates an expense when a to-do is completed.
library;

import 'package:intl/intl.dart';

import 'package:bachelor_buddy/core/diagnostics/logger.dart';
import 'package:bachelor_buddy/core/db/app_database.dart';
import 'package:bachelor_buddy/features/actions/action_intent.dart';
import 'package:bachelor_buddy/features/expenses/data/expense_repository.dart';
import 'package:bachelor_buddy/features/todo/data/todo_repository.dart';

class CreateExpenseActionHandler implements ActionHandler {
  final ExpenseRepository _expenseRepo;
  final TodoRepository _todoRepo;
  final AppDatabase _db;

  CreateExpenseActionHandler(this._expenseRepo, this._todoRepo, this._db);

  @override
  String get type => 'create_expense';

  @override
  Future<void> execute(ActionIntent intent) async {
    try {
      final payload = intent.payload;
      final amountPaise = payload['amountPaise'] as int? ?? 0;
      if (amountPaise <= 0) {
        AppLogger.warn('Cannot execute create_expense: amountPaise <= 0');
        return;
      }

      final categoryHint = payload['categoryHint'] as String? ?? 'Other';
      final note = payload['note'] as String? ?? 'From completed task';
      final todoId = payload['todoId'] as String?;
      final dateStr = payload['date'] as String? ??
          DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Resolve category from categoryHint
      final categories = await _db.select(_db.categories).get();
      final matchedCategory = categories.firstWhere(
        (c) => c.name.toLowerCase() == categoryHint.toLowerCase(),
        orElse: () => categories.firstWhere(
          (c) => c.kind == 'expense',
          orElse: () => categories.first,
        ),
      );

      // Create transaction
      await _expenseRepo.addTransaction(
        amountPaise: amountPaise,
        type: 'expense',
        categoryId: matchedCategory.id,
        note: note,
        date: dateStr,
        source: 'todo_action',
        sourceRefId: todoId,
      );

      // Update todo actionStatus if todoId is available
      if (todoId != null) {
        await _todoRepo.updateActionStatus(todoId, 'executed');
      }

      AppLogger.info(
        'Successfully auto-created expense of ₹${amountPaise ~/ 100} in ${matchedCategory.name} from todo',
        context: 'ActionRunner',
      );
    } catch (e, stack) {
      AppLogger.error(
        'Failed to execute create_expense action: $e\n$stack',
        context: 'ActionRunner',
      );
    }
  }
}
