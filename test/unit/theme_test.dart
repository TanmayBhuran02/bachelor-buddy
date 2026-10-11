import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bachelor_buddy/core/theme/app_theme.dart';
import 'package:bachelor_buddy/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppTheme.useGoogleFonts = false;

  group('AppTheme & Neobrutalism Tests', () {
    test('Default themeStyleProvider is neobrutalism', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeStyleProvider), AppThemeStyle.neobrutalism);
    });

    test('Can switch themeStyleProvider between styles', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(themeStyleProvider.notifier).state =
          AppThemeStyle.rawSketchbook;
      expect(container.read(themeStyleProvider), AppThemeStyle.rawSketchbook);

      container.read(themeStyleProvider.notifier).state =
          AppThemeStyle.neobrutalism;
      expect(container.read(themeStyleProvider), AppThemeStyle.neobrutalism);
    });

    test('AppTheme generates Neobrutalism light and dark themes with NeoCardBorder', () {
      final lightTheme = AppTheme.getLightTheme(AppThemeStyle.neobrutalism);
      final darkTheme = AppTheme.getDarkTheme(AppThemeStyle.neobrutalism);

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
      expect(lightTheme.cardTheme.shape, isA<NeoCardBorder>());
      expect(darkTheme.cardTheme.shape, isA<NeoCardBorder>());

      final neoBorder = lightTheme.cardTheme.shape as NeoCardBorder;
      expect(neoBorder.side.width, 2.5);
      expect(neoBorder.shadowOffset, const Offset(3.5, 3.5));
    });

    test('AppTheme generates Raw Sketchbook light and dark themes with RawCardBorder', () {
      final rawLight = AppTheme.getLightTheme(AppThemeStyle.rawSketchbook);
      final rawDark = AppTheme.getDarkTheme(AppThemeStyle.rawSketchbook);

      expect(rawLight.brightness, Brightness.light);
      expect(rawDark.brightness, Brightness.dark);
      expect(rawLight.cardTheme.shape, isA<RawCardBorder>());
      expect(rawDark.cardTheme.shape, isA<RawCardBorder>());
    });

    test('NeoCardBorder dimensions and equality', () {
      const border1 = NeoCardBorder();
      const border2 = NeoCardBorder();
      const border3 = NeoCardBorder(
        side: BorderSide(color: Colors.red, width: 3.0),
      );

      expect(border1, equals(border2));
      expect(border1.hashCode, equals(border2.hashCode));
      expect(border1 == border3, isFalse);
      expect(border1.dimensions, const EdgeInsets.all(2.5));
    });
  });
}
