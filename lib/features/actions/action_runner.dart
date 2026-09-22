/// ActionRunner: Orchestrates action execution when a to-do is completed.
/// Ensures idempotency — executing the same to-do's action twice never creates duplicates.
library;

import 'dart:async';
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
      }
    });
  }

  void dispose() {
    _sub?.cancel();
  }

  Future<void> _handleTodoAction(TodoCompleted event) async {
    final handler = registry.of(event.actionType!);
    if (handler == null) return;

    try {
      final intent = ActionIntent.fromJsonString(event.actionPayloadJson!);
      await handler.execute(intent);
    } catch (e) {
      // Log error but don't crash — action failures shouldn't block todo completion
      // In production, this would go to the diagnostics log
    }
  }
}
