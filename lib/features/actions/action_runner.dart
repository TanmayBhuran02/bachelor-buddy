/// ActionRunner: Orchestrates action execution when a to-do is completed.
/// Ensures idempotency — executing the same to-do's action twice never creates duplicates.
library;

import 'dart:async';
import 'package:bachelor_buddy/core/diagnostics/logger.dart';
import 'package:bachelor_buddy/core/events/domain_event.dart';
import 'action_intent.dart';

class ActionRunner {
  final ActionRegistry registry;
  final EventBus eventBus;
  StreamSubscription<TodoCompleted>? _sub;

  ActionRunner({required this.registry, required this.eventBus}) {
    start();
  }

  /// Listen for TodoCompleted events and trigger action execution
  void start() {
    _sub?.cancel();
    _sub = eventBus.on<TodoCompleted>().listen((event) {
      if (event.actionType != null && event.actionPayloadJson != null) {
        _handleTodoAction(event);
      } else {
        AppLogger.info(
          'Todo completed without automated action: "${event.title}"',
          context: 'ActionRunner',
        );
      }
    });
    AppLogger.info('ActionRunner listening for task actions', context: 'ActionRunner');
  }

  void dispose() {
    _sub?.cancel();
  }

  Future<void> _handleTodoAction(TodoCompleted event) async {
    final handler = registry.of(event.actionType!);
    if (handler == null) {
      AppLogger.warn(
        'No handler registered for action type: ${event.actionType}',
        context: 'ActionRunner',
      );
      return;
    }

    try {
      AppLogger.info(
        'Executing action "${event.actionType}" for todo "${event.title}"',
        context: 'ActionRunner',
      );
      final intent = ActionIntent.fromJsonString(event.actionPayloadJson!);
      await handler.execute(intent);
      AppLogger.info(
        'Successfully completed action "${event.actionType}" for "${event.title}"',
        context: 'ActionRunner',
      );
    } catch (e, stack) {
      AppLogger.error(
        'Action "${event.actionType}" failed: $e\n$stack',
        context: 'ActionRunner',
      );
    }
  }
}
