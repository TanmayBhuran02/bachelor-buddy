/// MaterialApp.router with theme configuration and Riverpod providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/security/biometric_lock_screen.dart';
import 'core/notifications/notification_service.dart';
import 'router.dart';
import 'providers.dart';

class BachelorBuddyApp extends ConsumerWidget {
  const BachelorBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themeStyle = ref.watch(themeStyleProvider);
    final sketchbookPalette = ref.watch(sketchbookPaletteProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final router = ref.watch(routerProvider);

    if (isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.processPendingPayload();
      });
    }

    return MaterialApp.router(
      title: 'Bachelor Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(themeStyle, sketchbookPalette),
      darkTheme: AppTheme.getDarkTheme(themeStyle, sketchbookPalette),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        if (!isAuthenticated) {
          return const BiometricLockScreen();
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
