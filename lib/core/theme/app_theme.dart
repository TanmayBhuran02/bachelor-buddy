/// Anti-polish / raw aesthetic theme for Bachelor Buddy.
/// Space Mono typography, paper/pencil/kraft palette, hand-drawn wobbly borders.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hand-drawn wobbly card border matching raw sketchbook / notebook aesthetic.
class RawCardBorder extends OutlinedBorder {
  const RawCardBorder({
    super.side = const BorderSide(color: Color(0xFF1A1A1A), width: 1.5),
    this.seed = 0,
    this.variance = 2.5,
  });

  final int seed;
  final double variance;

  @override
  OutlinedBorder copyWith({BorderSide? side, int? seed, double? variance}) {
    return RawCardBorder(
      side: side ?? this.side,
      seed: seed ?? this.seed,
      variance: variance ?? this.variance,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _buildPath(rect.deflate(side.width));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _buildPath(rect);
  }

  Path _buildPath(Rect rect) {
    if (rect.isEmpty) return Path();

    // Use deterministic hash of dimensions and seed for stability across rebuilds
    final int h = ((rect.width * 17.0).round() ^
            (rect.height * 31.0).round() ^
            (seed * 101))
        .abs();

    // Deterministic pseudo-random in [-variance, variance]
    double v(int step, double scale) {
      final int n = (h + step * 47) % 1000;
      return (n / 500.0 - 1.0) * variance * scale;
    }

    final l = rect.left + side.width / 2;
    final t = rect.top + side.width / 2;
    final r = rect.right - side.width / 2;
    final b = rect.bottom - side.width / 2;
    final w = r - l;
    final hgt = b - t;

    // Corner points with hand-drawn offsets
    final pTL = Offset(l + 2.0 + v(1, 0.6), t + 3.0 + v(2, 0.8));
    final pTR = Offset(r - 2.5 + v(3, 0.7), t + 2.0 + v(4, 0.6));
    final pBR = Offset(r - 3.0 + v(5, 0.8), b - 2.5 + v(6, 0.7));
    final pBL = Offset(l + 2.5 + v(7, 0.7), b - 1.5 + v(8, 0.5));

    final path = Path();
    path.moveTo(pTL.dx, pTL.dy);

    // Top edge: subtle bow / organic slope
    path.cubicTo(
      l + w * 0.33,
      t + 1.0 + v(9, 1.0),
      l + w * 0.67,
      t + 1.5 + v(10, 0.8),
      pTR.dx,
      pTR.dy,
    );

    // Right edge: slight inward tilt / hand curve
    path.cubicTo(
      r - 1.5 + v(11, 0.8),
      t + hgt * 0.35,
      r - 2.5 + v(12, 1.0),
      t + hgt * 0.65,
      pBR.dx,
      pBR.dy,
    );

    // Bottom edge: gentle sag / natural hand line
    path.cubicTo(
      l + w * 0.65,
      b - 1.0 + v(13, 0.8),
      l + w * 0.35,
      b + 1.0 + v(14, 1.0),
      pBL.dx,
      pBL.dy,
    );

    // Left edge: slight organic wave
    path.cubicTo(
      l + 1.5 + v(15, 1.0),
      t + hgt * 0.65,
      l + 1.0 + v(16, 0.8),
      t + hgt * 0.35,
      pTL.dx,
      pTL.dy,
    );

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    final path = _buildPath(rect);
    final paint = Paint()
      ..color = side.color
      ..strokeWidth = side.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return RawCardBorder(
      side: side.scale(t),
      seed: seed,
      variance: variance * t,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is RawCardBorder &&
        other.side == side &&
        other.seed == seed &&
        other.variance == variance;
  }

  @override
  int get hashCode => Object.hash(side, seed, variance);
}

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

  // Light surfaces — warm parchment sketchbook (matches image)
  static const lightPaperScaffold = Color(0xFFF7F5EE);
  static const lightCardBg = Color(0xFFFFFEEF);
  static const lightBorder = Color(0xFF1A1A1A);
  static const lightSurfaceContainer = Color(0xFFECE7DA);
  static const lightTrack = Color(0xFFE2DCCF);

  // Dynamic context-aware helpers
  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? paperWhite
          : markerBlack;

  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF888888)
          : const Color(0xFF666666);

  static Color textSubtle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF555555)
          : const Color(0xFF888888);

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3A3A3A)
          : const Color(0xFF1A1A1A);

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1F1F1F)
          : const Color(0xFFECE7DA);

  static Color track(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : const Color(0xFFE2DCCF);

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? cardDark
          : lightCardBg;
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
      textTheme: _textTheme(AppColors.paperWhite),
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
        clipBehavior: Clip.antiAlias,
        shape: const RawCardBorder(
          side: BorderSide(
            color: Color(0xFF3A3A3A),
            width: 1.5,
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
        shape: const RawCardBorder(
          side: BorderSide(
            color: AppColors.markerBlack,
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHighDark,
        labelStyle: GoogleFonts.spaceMono(
          fontSize: 11,
          letterSpacing: 0.3,
          color: AppColors.paperWhite,
        ),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        shape: const RawCardBorder(
          side: BorderSide(color: Color(0xFF3A3A3A), width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.paperWhite;
          }
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
          shape: const RawCardBorder(
            side: BorderSide(color: AppColors.paperWhite, width: 1.5),
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
          side: const BorderSide(color: Color(0xFF555555), width: 1.5),
          shape: const RawCardBorder(
            side: BorderSide(color: Color(0xFF555555), width: 1.5),
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
      surface: AppColors.lightPaperScaffold,
      surfaceContainerLowest: AppColors.lightPaperScaffold,
      surfaceContainerLow: const Color(0xFFF0ECE0),
      surfaceContainer: AppColors.lightSurfaceContainer,
      surfaceContainerHigh: const Color(0xFFE5DFC9),
      surfaceContainerHighest: const Color(0xFFDCD5BE),
      error: AppColors.tertiary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightPaperScaffold,
      textTheme: _textTheme(AppColors.markerBlack),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.lightPaperScaffold,
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
        color: AppColors.lightCardBg,
        clipBehavior: Clip.antiAlias,
        shape: const RawCardBorder(
          side: BorderSide(
            color: AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightPaperScaffold,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.markerBlack,
              letterSpacing: 0.5,
            );
          }
          return GoogleFonts.spaceMono(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF777777),
            letterSpacing: 0.5,
          );
        }),
        height: 64,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.markerBlack,
        foregroundColor: AppColors.lightCardBg,
        elevation: 0,
        shape: const RawCardBorder(
          side: BorderSide(
            color: AppColors.markerBlack,
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceContainer,
        labelStyle: GoogleFonts.spaceMono(
          fontSize: 11,
          letterSpacing: 0.3,
          color: AppColors.markerBlack,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        side: const BorderSide(color: AppColors.lightBorder, width: 1.2),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.markerBlack,
        contentTextStyle: GoogleFonts.spaceMono(
          color: AppColors.lightCardBg,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFD6CFC0),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide:
              const BorderSide(color: AppColors.markerBlack, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.spaceMono(
          fontSize: 12,
          color: const Color(0xFF666666),
        ),
        hintStyle: GoogleFonts.spaceMono(
          fontSize: 12,
          color: const Color(0xFF888888),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCardBg,
        shape: const RawCardBorder(
          side: BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.markerBlack;
          }
          return const Color(0xFF888888);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.3);
          }
          return const Color(0xFFD0C9BA);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.markerBlack,
          foregroundColor: AppColors.lightCardBg,
          shape: const RawCardBorder(
            side: BorderSide(color: AppColors.markerBlack, width: 1.5),
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
          foregroundColor: AppColors.markerBlack,
          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
          shape: const RawCardBorder(
            side: BorderSide(color: AppColors.lightBorder, width: 1.5),
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
          foregroundColor: AppColors.markerBlack,
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
        side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.markerBlack;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.lightCardBg),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }

  static TextTheme _textTheme(Color defaultTextColor) => TextTheme(
        displayLarge: GoogleFonts.spaceMono(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -2,
          color: defaultTextColor,
        ),
        displayMedium: GoogleFonts.spaceMono(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          color: defaultTextColor,
        ),
        displaySmall: GoogleFonts.spaceMono(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: defaultTextColor,
        ),
        headlineLarge: GoogleFonts.spaceMono(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: defaultTextColor,
        ),
        headlineMedium: GoogleFonts.spaceMono(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: defaultTextColor,
        ),
        headlineSmall: GoogleFonts.spaceMono(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: defaultTextColor,
        ),
        titleLarge: GoogleFonts.spaceMono(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: defaultTextColor,
        ),
        titleMedium: GoogleFonts.spaceMono(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: defaultTextColor,
        ),
        titleSmall: GoogleFonts.spaceMono(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: defaultTextColor,
        ),
        bodyLarge: GoogleFonts.spaceMono(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: defaultTextColor,
        ),
        bodyMedium: GoogleFonts.spaceMono(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: defaultTextColor,
        ),
        bodySmall: GoogleFonts.spaceMono(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: defaultTextColor,
        ),
        labelLarge: GoogleFonts.spaceMono(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: defaultTextColor,
        ),
        labelMedium: GoogleFonts.spaceMono(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: defaultTextColor,
        ),
        labelSmall: GoogleFonts.spaceMono(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: defaultTextColor,
        ),
      );
}
