import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/core/security/biometric_service.dart';
import 'package:bachelor_buddy/providers.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptAuth();
    });
  }

  Future<void> _promptAuth() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    final success = await BiometricService.authenticate(
      reason: 'Scan fingerprint to unlock Bachelor Buddy',
    );

    if (mounted) {
      setState(() => _isAuthenticating = false);
      if (success) {
        ref.read(isAuthenticatedProvider.notifier).state = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border(context), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'BACHELOR BUDDY',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'App is locked with biometrics',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                ),
                const SizedBox(height: 36),
                FilledButton.icon(
                  onPressed: _isAuthenticating ? null : _promptAuth,
                  icon: const Icon(Icons.lock_open, size: 18),
                  label: Text(_isAuthenticating ? 'VERIFYING...' : 'UNLOCK APP'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
