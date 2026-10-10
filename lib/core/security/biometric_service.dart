import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:bachelor_buddy/core/diagnostics/logger.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports biometrics
  static Future<bool> isBiometricsAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException catch (e) {
      AppLogger.warn('Biometrics availability check error: $e', context: 'Security');
      return false;
    }
  }

  /// Trigger biometric authentication prompt
  static Future<bool> authenticate({String reason = 'Authenticate to access Bachelor Buddy'}) async {
    try {
      final available = await isBiometricsAvailable();
      if (!available) {
        return false;
      }
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // fallback to device pin/pattern if needed
        ),
      );
    } on PlatformException catch (e) {
      AppLogger.error('Biometric authentication failed: $e', context: 'Security');
      return false;
    }
  }
}
