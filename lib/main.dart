/// Application entry point.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/widgets_sync/widget_callbacks.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register widget background callbacks
  await registerWidgetCallbacks();

  runApp(
    const ProviderScope(
      child: BachelorBuddyApp(),
    ),
  );
}
