/// Background callback entry point for interactive widget actions.
/// This runs in its own isolate — it must NOT depend on Flutter UI or Riverpod.
/// It opens the DB directly, mutates, and refreshes the widget.
library;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:bachelor_buddy/core/diagnostics/logger.dart';

/// Top-level entry point for widget background callbacks.
/// Must be annotated for AOT compilation.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;

  AppLogger.info('Widget callback: $uri', context: 'WidgetCallback');

  try {
    final action = uri.host;
    final params = uri.queryParameters;

    switch (action) {
      case 'tiffin_mark_received':
        await _handleTiffinMarkReceived(params);
      case 'todo_toggle':
        await _handleTodoToggle(params);
      case 'water_add_glass':
        await _handleWaterAddGlass(params);
      default:
        AppLogger.warn('Unknown widget action: $action', context: 'WidgetCallback');
    }
  } catch (e, stack) {
    AppLogger.error(
      'Widget callback error: $e\n$stack',
      context: 'WidgetCallback',
    );
  }
}

Future<void> _handleTiffinMarkReceived(Map<String, String> params) async {
  // TODO: Open DB directly, update tiffin log status, create linked expense,
  // refresh tiffin widget snapshot
  final planId = params['planId'];
  final date = params['date'];
  AppLogger.info(
    'Marking tiffin received: plan=$planId date=$date',
    context: 'WidgetCallback',
  );
}

Future<void> _handleTodoToggle(Map<String, String> params) async {
  // TODO: Open DB, toggle todo isDone, fire event, refresh todo widget
  final todoId = params['todoId'];
  AppLogger.info(
    'Toggling todo: id=$todoId',
    context: 'WidgetCallback',
  );
}

Future<void> _handleWaterAddGlass(Map<String, String> params) async {
  // TODO: Open DB, insert water log, refresh water widget
  AppLogger.info(
    'Adding water glass from widget',
    context: 'WidgetCallback',
  );
}

/// Register the background callback with home_widget
Future<void> registerWidgetCallbacks() async {
  if (kIsWeb) return;
  await HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
}
