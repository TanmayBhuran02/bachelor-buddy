/// Action pipeline: Intent, Handler, Registry, and Runner.
/// This is the architecture that enables to-do → expense automation.
library;

import 'dart:convert';

// ─── Action Intent ─────────────────────────────────────────────────────────

class ActionIntent {
  final String type; // e.g. 'create_expense'
  final Map<String, dynamic> payload;
  final double confidence;

  ActionIntent({
    required this.type,
    required this.payload,
    this.confidence = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'confidence': confidence,
        'payload': payload,
      };

  factory ActionIntent.fromJson(Map<String, dynamic> json) => ActionIntent(
        type: json['type'] as String,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
        payload: Map<String, dynamic>.from(json['payload'] as Map),
      );

  String toJsonString() => jsonEncode(toJson());

  factory ActionIntent.fromJsonString(String json) =>
      ActionIntent.fromJson(jsonDecode(json) as Map<String, dynamic>);
}

// ─── Action Handler ────────────────────────────────────────────────────────

abstract class ActionHandler {
  String get type;
  Future<void> execute(ActionIntent intent);
}

// ─── Action Registry ───────────────────────────────────────────────────────

class ActionRegistry {
  final Map<String, ActionHandler> _handlers = {};

  void register(ActionHandler handler) {
    _handlers[handler.type] = handler;
  }

  ActionHandler? of(String type) => _handlers[type];

  bool has(String type) => _handlers.containsKey(type);

  List<String> get registeredTypes => _handlers.keys.toList();
}

// ─── Intent Parser ─────────────────────────────────────────────────────────

abstract class IntentParser {
  Future<ActionIntent?> parse(String todoText);
}

/// MVP: returns null for all inputs. Placeholder for AI integration.
class NoopIntentParser implements IntentParser {
  @override
  Future<ActionIntent?> parse(String todoText) async => null;
}
