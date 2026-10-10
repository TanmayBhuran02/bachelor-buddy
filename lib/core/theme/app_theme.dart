/// Anti-polish / raw aesthetic theme for Bachelor Buddy.
/// Space Mono typography, paper/pencil/kraft palette, hard edges, no smooth polish.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette — muted indigo, functional not flashy
  static const primary = Color(0xFF5A5A8F);
  static const primaryLight = Color(0xFF7E7EB0);
  static const primaryDark = Color(0xFF3D3D6B);

  // Secondary palette (muted teal — income, positive states)
  static const secondary = Color(0xFF3A8C7A);
  static const secondaryLight = Color(0xFF5BB09E);
  static const secondaryDark = Color(0xFF1F6B5A);

  // Tertiary palette (muted rust — expenses, warnings)
  static const tertiary = Color(0xFFC45B4A);
  static const tertiaryLight = Color(0xFFD4847A);
  static const tertiaryDark = Color(0xFF9A3D2E);

  // Warning — muted amber
  static const warning = Color(0xFFB89545);
  static const warningDark = Color(0xFF8E6F2A);

  // Budget states
  static const budgetGreen = Color(0xFF4A8A4E);
  static const budgetAmber = Color(0xFFB89545);
  static const budgetRed = Color(0xFFC45B4A);

  // Paper / Raw surfaces
  static const paperWhite = Color(0xFFFAFAF8);
  static const pencilGrey = Color(0xFF4A4A4A);
  static const markerBlack = Color(0xFF1A1A1A);
  static const kraftBrown = Color(0xFFC4A77D);

  // Dark surfaces — raw, no blue tint
  static const surfaceDark = Color(0xFF111111);
  static const cardDark = Color(0xFF1A1A1A);
  static const surfaceContainerDark = Color(0xFF1A1A1A);
  static const surfaceContainerHighDark = Color(0xFF252525);
  static const surfaceContainerHighestDark = Color(0xFF333333);

  // Priority colors
  static const priorityHigh = Color(0xFFC45B4A);
  static const priorityMedium = Color(0xFFB89545);
  static const priorityLow = Color(0xFF4A8A4E);
}

class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.surfaceDark,
      surfaceContainerLowest: AppColors.surfaceDark,
      surfaceContainerLow: const Color(0xFF161616),
      surfaceContainer: AppColors.surfaceContainerDark,
      surfaceContainerHigh: AppColors.surfaceContainerHighDark,
      surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
      error: AppColors.tertiary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceDark,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.paperWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.spaceMono(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.paperWhite,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(
            color: Color(0xFF3A3A3A),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.paperWhite,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.spaceMono(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF666666),
            letterSpacing: 0.5,
          );
        }),
        height: 64,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.paperWhite,
        foregroundColor: AppColors.markerBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(
            color: AppColors.markerBlack,
            width: 2,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHighDark,
        labelStyle: GoogleFonts.spaceMono(fontSize: 11, letterSpacing: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        side: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighestDark,
        contentTextStyle: GoogleFonts.spaceMono(
          color: AppColors.paperWhite,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3A3A),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHighDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.paperWhite, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.spaceMono(
          fontSize: 12,
          color: const Color(0xFF888888),
        ),
        hintStyle: GoogleFonts.spaceMono(
          fontSize: 12,
          color: const Color(0xFF555555),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: Color(0xFF3A3A3A)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.paperWhite;
          return const Color(0xFF666666);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return const Color(0xFF333333);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.paperWhite,
          foregroundColor: AppColors.markerBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          textStyle: GoogleFonts.spaceMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.paperWhite,
          side: const BorderSide(color: Color(0xFF555555)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          textStyle: GoogleFonts.spaceMono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.paperWhite,
          textStyle: GoogleFonts.spaceMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
        side: const BorderSide(color: Color(0xFF555555), width: 1.5),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      surface: AppColors.paperWhite,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paperWhite,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.paperWhite,
        foregroundColor: AppColors.markerBlack,
        titleTextStyle: GoogleFonts.spaceMono(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.markerBlack,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: BorderSide(
            color: AppColors.pencilGrey.withValues(alpha: 0.3),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.markerBlack,
        foregroundColor: AppColors.paperWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  static TextTheme get _textTheme => TextTheme(
        displayLarge: GoogleFonts.spaceMono(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -2,
        ),
        displayMedium: GoogleFonts.spaceMono(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
        ),
        displaySmall: GoogleFonts.spaceMono(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        headlineLarge: GoogleFonts.spaceMono(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
        ),
        headlineMedium: GoogleFonts.spaceMono(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineSmall: GoogleFonts.spaceMono(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.spaceMono(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.spaceMono(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        titleSmall: GoogleFonts.spaceMono(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        bodyLarge: GoogleFonts.spaceMono(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodyMedium: GoogleFonts.spaceMono(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        bodySmall: GoogleFonts.spaceMono(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
        labelLarge: GoogleFonts.spaceMono(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.spaceMono(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.spaceMono(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      );
}
