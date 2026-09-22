/// Domain events and in-process event bus.
/// Features communicate cross-feature effects exclusively through typed events.
library;

import 'dart:async';

// ─── Domain Events ─────────────────────────────────────────────────────────

sealed class DomainEvent {
  final DateTime timestamp;
  DomainEvent() : timestamp = DateTime.now();
}

// Expense / Transaction events
class TransactionCreated extends DomainEvent {
  final String transactionId;
  final int amountPaise;
  final String type;
  final String categoryId;
  final String date;
  final String source;
  TransactionCreated({
    required this.transactionId,
    required this.amountPaise,
    required this.type,
    required this.categoryId,
    required this.date,
    required this.source,
  });
}

class TransactionUpdated extends DomainEvent {
  final String transactionId;
  final int amountPaise;
  final String type;
  final String categoryId;
  final String date;
  TransactionUpdated({
    required this.transactionId,
    required this.amountPaise,
    required this.type,
    required this.categoryId,
    required this.date,
  });
}

class TransactionDeleted extends DomainEvent {
  final String transactionId;
  final int amountPaise;
  final String type;
  final String categoryId;
  final String date;
  TransactionDeleted({
    required this.transactionId,
    required this.amountPaise,
    required this.type,
    required this.categoryId,
    required this.date,
  });
}

class ExpenseAdded extends DomainEvent {
  final String transactionId;
  final int amountPaise;
  final String categoryId;
  final String source;
  ExpenseAdded({
    required this.transactionId,
    required this.amountPaise,
    required this.categoryId,
    required this.source,
  });
}

class ExpenseUpdated extends DomainEvent {
  final String transactionId;
  final int oldAmountPaise;
  final int newAmountPaise;
  ExpenseUpdated({
    required this.transactionId,
    required this.oldAmountPaise,
    required this.newAmountPaise,
  });
}

class ExpenseDeleted extends DomainEvent {
  final String transactionId;
  final int amountPaise;
  final String categoryId;
  ExpenseDeleted({
    required this.transactionId,
    required this.amountPaise,
    required this.categoryId,
  });
}

// Budget events
class BudgetExceeded extends DomainEvent {
  final String month; // YYYY-MM
  final String? categoryId; // null = overall
  final double percent;
  BudgetExceeded({
    required this.month,
    this.categoryId,
    required this.percent,
  });
}

// Tiffin events
class TiffinReceived extends DomainEvent {
  final String planId;
  final String date;
  final int pricePaise;
  final String mealType;
  TiffinReceived({
    required this.planId,
    required this.date,
    required this.pricePaise,
    required this.mealType,
  });
}

class TiffinSkipped extends DomainEvent {
  final String planId;
  final String date;
  TiffinSkipped({
    required this.planId,
    required this.date,
  });
}

class TiffinLogged extends DomainEvent {
  final String logId;
  final String planId;
  final String status; // received, skipped, pending
  final String date;
  TiffinLogged({
    required this.logId,
    required this.planId,
    required this.status,
    required this.date,
  });
}

class TiffinStatusChanged extends DomainEvent {
  final String logId;
  final String oldStatus;
  final String newStatus;
  TiffinStatusChanged({
    required this.logId,
    required this.oldStatus,
    required this.newStatus,
  });
}

// Todo events
class TodoCompleted extends DomainEvent {
  final String todoId;
  final String title;
  final String? actionType;
  final String? actionPayloadJson;
  TodoCompleted({
    required this.todoId,
    required this.title,
    this.actionType,
    this.actionPayloadJson,
  });
}

class TodoCreated extends DomainEvent {
  final String todoId;
  final String title;
  TodoCreated({required this.todoId, required this.title});
}

class TodoUpdated extends DomainEvent {
  final String todoId;
  final String title;
  TodoUpdated({required this.todoId, required this.title});
}

// Water events
class WaterLogged extends DomainEvent {
  final int amountMl;
  final int dailyTotalMl;
  final int goalMl;
  WaterLogged({
    required this.amountMl,
    required this.dailyTotalMl,
    required this.goalMl,
  });
}

// ─── Event Bus ─────────────────────────────────────────────────────────────

class EventBus {
  static final EventBus _instance = EventBus._();
  factory EventBus() => _instance;
  EventBus._();

  final _controller = StreamController<DomainEvent>.broadcast();

  Stream<DomainEvent> get stream => _controller.stream;

  /// Listen to a specific event type
  Stream<T> on<T extends DomainEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  /// Fire an event to all listeners
  void fire(DomainEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
