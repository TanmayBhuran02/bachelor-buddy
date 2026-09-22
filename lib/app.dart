/// MaterialApp.router with theme configuration and Riverpod providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'router.dart';
import 'providers.dart';

class BachelorBuddyApp extends ConsumerWidget {
  const BachelorBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final showOnboarding = ref.watch(showOnboardingProvider);
    final router = createRouter(showOnboarding: showOnboarding);

    return MaterialApp.router(
      title: 'Bachelor Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
