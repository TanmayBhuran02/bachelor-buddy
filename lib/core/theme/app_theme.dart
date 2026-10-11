/// Neo-brutalism and Raw sketchbook aesthetic themes for Bachelor Buddy.
/// Supports both Neobrutalism (bold borders, hard offset drop shadows, punchy colors)
/// and Raw sketchbook (Space Mono, hand-drawn wobbly borders, paper/pencil tones).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Available aesthetic styles for the entire app.
enum AppThemeStyle {
  neobrutalism,
  rawSketchbook,
}

/// ThemeExtension providing custom design tokens to widgets.
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.style,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.tertiaryAccent,
    required this.warningAccent,
    required this.borderStroke,
    required this.cardSurface,
    required this.shadowOffset,
  });

  final AppThemeStyle style;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color tertiaryAccent;
  final Color warningAccent;
  final Color borderStroke;
  final Color cardSurface;
  final Offset shadowOffset;

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    AppThemeStyle? style,
    Color? primaryAccent,
    Color? secondaryAccent,
    Color? tertiaryAccent,
    Color? warningAccent,
    Color? borderStroke,
    Color? cardSurface,
    Offset? shadowOffset,
  }) {
    return AppThemeExtension(
      style: style ?? this.style,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      secondaryAccent: secondaryAccent ?? this.secondaryAccent,
      tertiaryAccent: tertiaryAccent ?? this.tertiaryAccent,
      warningAccent: warningAccent ?? this.warningAccent,
      borderStroke: borderStroke ?? this.borderStroke,
      cardSurface: cardSurface ?? this.cardSurface,
      shadowOffset: shadowOffset ?? this.shadowOffset,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      style: t < 0.5 ? style : other.style,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      secondaryAccent: Color.lerp(secondaryAccent, other.secondaryAccent, t)!,
      tertiaryAccent: Color.lerp(tertiaryAccent, other.tertiaryAccent, t)!,
      warningAccent: Color.lerp(warningAccent, other.warningAccent, t)!,
      borderStroke: Color.lerp(borderStroke, other.borderStroke, t)!,
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      shadowOffset: Offset.lerp(shadowOffset, other.shadowOffset, t)!,
    );
  }
}

/// Neo-brutalist card border: solid stroke + hard zero-blur offset shadow.
class NeoCardBorder extends OutlinedBorder {
  const NeoCardBorder({
    super.side = const BorderSide(color: Color(0xFF000000), width: 2.5),
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
    this.shadowOffset = const Offset(3.5, 3.5),
    this.shadowColor = const Color(0xFF000000),
  });

  final BorderRadius borderRadius;
  final Offset shadowOffset;
  final Color shadowColor;

  @override
  OutlinedBorder copyWith({
    BorderSide? side,
    BorderRadius? borderRadius,
    Offset? shadowOffset,
    Color? shadowColor,
  }) {
    return NeoCardBorder(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.toRRect(rect.deflate(side.width)));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.toRRect(rect));
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final rrect = borderRadius.toRRect(rect);

    // Hard drop shadow (zero blur) offset behind the card
    if (shadowOffset != Offset.zero && shadowColor.a > 0) {
      final cardPath = Path()..addRRect(rrect);
      final shadowPath = Path()..addRRect(borderRadius.toRRect(rect.shift(shadowOffset)));
      final visibleShadow = Path.combine(PathOperation.difference, shadowPath, cardPath);

      final shadowPaint = Paint()
        ..color = shadowColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(visibleShadow, shadowPaint);
    }

    // High contrast crisp border
    if (side.style != BorderStyle.none && side.width > 0) {
      final borderPaint = Paint()
        ..color = side.color
        ..strokeWidth = side.width
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(rrect, borderPaint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return NeoCardBorder(
      side: side.scale(t),
      borderRadius: borderRadius * t,
      shadowOffset: shadowOffset * t,
      shadowColor: shadowColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is NeoCardBorder &&
        other.side == side &&
        other.borderRadius == borderRadius &&
        other.shadowOffset == shadowOffset &&
        other.shadowColor == shadowColor;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius, shadowOffset, shadowColor);
}

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

    final int h = ((rect.width * 17.0).round() ^
            (rect.height * 31.0).round() ^
            (seed * 101))
        .abs();

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

    final pTL = Offset(l + 2.0 + v(1, 0.6), t + 3.0 + v(2, 0.8));
    final pTR = Offset(r - 2.5 + v(3, 0.7), t + 2.0 + v(4, 0.6));
    final pBR = Offset(r - 3.0 + v(5, 0.8), b - 2.5 + v(6, 0.7));
    final pBL = Offset(l + 2.5 + v(7, 0.7), b - 1.5 + v(8, 0.5));

    final path = Path();
    path.moveTo(pTL.dx, pTL.dy);

    path.cubicTo(
      l + w * 0.33,
      t + 1.0 + v(9, 1.0),
      l + w * 0.67,
      t + 1.5 + v(10, 0.8),
      pTR.dx,
      pTR.dy,
    );

    path.cubicTo(
      r - 1.5 + v(11, 0.8),
      t + hgt * 0.35,
      r - 2.5 + v(12, 1.0),
      t + hgt * 0.65,
      pBR.dx,
      pBR.dy,
    );

    path.cubicTo(
      l + w * 0.65,
      b - 1.0 + v(13, 0.8),
      l + w * 0.35,
      b + 1.0 + v(14, 1.0),
      pBL.dx,
      pBL.dy,
    );

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
  // Neobrutalism palette
  static const neoYellow = Color(0xFFFFE600);
  static const neoCyan = Color(0xFF00F0FF);
  static const neoPink = Color(0xFFFF5376);
  static const neoGreen = Color(0xFF4EFA82);
  static const neoPurple = Color(0xFFA259FF);
  static const neoOrange = Color(0xFFFF8A00);
  static const neoBlack = Color(0xFF000000);
  static const neoWhite = Color(0xFFFFFFFF);
  static const neoScaffoldLight = Color(0xFFFDFBF7);
  static const neoScaffoldDark = Color(0xFF121212);
  static const neoCardDark = Color(0xFF1E1E1E);
  static const neoSurfaceDark = Color(0xFF252525);
  static const neoSurfaceLight = Color(0xFFF4F0E6);
  static const neoTrackDark = Color(0xFF333333);
  static const neoTrackLight = Color(0xFFEFE8DA);

  // Primary palette — default / raw
  static const primary = Color(0xFF5A5A8F);
  static const primaryLight = Color(0xFF7E7EB0);
  static const primaryDark = Color(0xFF3D3D6B);

  // Secondary palette (muted teal / cyan)
  static const secondary = Color(0xFF3A8C7A);
  static const secondaryLight = Color(0xFF5BB09E);
  static const secondaryDark = Color(0xFF1F6B5A);

  // Tertiary palette (muted rust / coral)
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

  // Light surfaces — warm parchment sketchbook
  static const lightPaperScaffold = Color(0xFFF7F5EE);
  static const lightCardBg = Color(0xFFFFFEEF);
  static const lightBorder = Color(0xFF1A1A1A);
  static const lightSurfaceContainer = Color(0xFFECE7DA);
  static const lightTrack = Color(0xFFE2DCCF);

  static AppThemeStyle styleOf(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.style ??
      AppThemeStyle.neobrutalism;

  // Dynamic context-aware helpers
  static Color text(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = styleOf(context);
    if (style == AppThemeStyle.neobrutalism) {
      return isDark ? neoWhite : neoBlack;
    }
    return isDark ? paperWhite : markerBlack;
  }

  static Color textMuted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = styleOf(context);
    if (style == AppThemeStyle.neobrutalism) {
      return isDark ? const Color(0xFFBBBBBB) : const Color(0xFF444444);
    }
    return isDark ? const Color(0xFF888888) : const Color(0xFF666666);
  }

  static Color textSubtle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = styleOf(context);
    if (style == AppThemeStyle.neobrutalism) {
      return isDark ? const Color(0xFF888888) : const Color(0xFF666666);
    }
    return isDark ? const Color(0xFF555555) : const Color(0xFF888888);
  }

  static Color border(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = styleOf(context);
    if (style == AppThemeStyle.neobrutalism) {
      return isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    }
    return isDark ? const Color(0xFF3A3A3A) : const Color(0xFF1A1A1A);
  }

  static Color surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = styleOf(context);
    if (style == AppThemeStyle.neobrutalism) {
      return isDark ? neoSurfaceDark : neoSurfaceLight;
    }
    return isDark ? const Color(0xFF1F1F1F) : const Color(0xFFECE7DA);
  }

  static Color track(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = styleOf(context);
    if (style == AppThemeStyle.neobrutalism) {
      return isDark ? neoTrackDark : neoTrackLight;
    }
    return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2DCCF);
  }

  static Color card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = styleOf(context);
    if (style == AppThemeStyle.neobrutalism) {
      return isDark ? neoCardDark : neoWhite;
    }
    return isDark ? cardDark : lightCardBg;
  }
}

class AppTheme {
  /// Toggleable for testing environments where HTTP font download is unavailable.
  static bool useGoogleFonts = true;

  static TextStyle _fontStyle({
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    Color? color,
  }) {
    if (!useGoogleFonts) {
      return TextStyle(
        fontFamily: 'SpaceMono',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
    return GoogleFonts.spaceMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static ThemeData get lightTheme => getLightTheme(AppThemeStyle.neobrutalism);
  static ThemeData get darkTheme => getDarkTheme(AppThemeStyle.neobrutalism);

  static ThemeData getLightTheme([AppThemeStyle style = AppThemeStyle.neobrutalism]) {
    return style == AppThemeStyle.neobrutalism
        ? _buildNeobrutalismTheme(brightness: Brightness.light)
        : _buildRawTheme(brightness: Brightness.light);
  }

  static ThemeData getDarkTheme([AppThemeStyle style = AppThemeStyle.neobrutalism]) {
    return style == AppThemeStyle.neobrutalism
        ? _buildNeobrutalismTheme(brightness: Brightness.dark)
        : _buildRawTheme(brightness: Brightness.dark);
  }

  // ─── NEOBRUTALISM THEME BUILDER ──────────────────────────────────────────

  static ThemeData _buildNeobrutalismTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.neoYellow,
      onPrimary: AppColors.neoBlack,
      secondary: AppColors.neoCyan,
      onSecondary: AppColors.neoBlack,
      tertiary: AppColors.neoPink,
      onTertiary: AppColors.neoWhite,
      error: AppColors.neoPink,
      onError: AppColors.neoWhite,
      surface: isDark ? AppColors.neoScaffoldDark : AppColors.neoScaffoldLight,
      onSurface: isDark ? AppColors.neoWhite : AppColors.neoBlack,
      outline: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
    );

    final borderColor = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
    final cardBg = isDark ? AppColors.neoCardDark : AppColors.neoWhite;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? AppColors.neoScaffoldDark : AppColors.neoScaffoldLight,
      textTheme: _neoTextTheme(isDark ? AppColors.neoWhite : AppColors.neoBlack),
      extensions: [
        AppThemeExtension(
          style: AppThemeStyle.neobrutalism,
          primaryAccent: AppColors.neoYellow,
          secondaryAccent: AppColors.neoCyan,
          tertiaryAccent: AppColors.neoPink,
          warningAccent: AppColors.neoOrange,
          borderStroke: borderColor,
          cardSurface: cardBg,
          shadowOffset: const Offset(3.5, 3.5),
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.neoScaffoldDark : AppColors.neoScaffoldLight,
        foregroundColor: isDark ? AppColors.neoWhite : AppColors.neoBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF444444) : const Color(0xFF000000),
            width: 2.5,
          ),
        ),
        titleTextStyle: _fontStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.neoWhite : AppColors.neoBlack,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        clipBehavior: Clip.none,
        shape: NeoCardBorder(
          side: BorderSide(color: borderColor, width: 2.5),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          shadowOffset: const Offset(3.5, 3.5),
          shadowColor: const Color(0xFF000000),
        ),
        margin: const EdgeInsets.only(left: 16, right: 20, top: 6, bottom: 10),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.neoScaffoldDark : AppColors.neoScaffoldLight,
        indicatorColor: AppColors.neoYellow,
        surfaceTintColor: Colors.transparent,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: Color(0xFF000000), width: 2.0),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _fontStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.neoWhite : AppColors.neoBlack,
              letterSpacing: 0.5,
            );
          }
          return _fontStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF777777),
            letterSpacing: 0.5,
          );
        }),
        height: 68,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.neoYellow,
        foregroundColor: AppColors.neoBlack,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: NeoCardBorder(
          side: BorderSide(color: Color(0xFF000000), width: 2.5),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          shadowOffset: Offset(4, 4),
          shadowColor: Color(0xFF000000),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF222222) : const Color(0xFFFFFFFF),
        labelStyle: _fontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: isDark ? AppColors.neoWhite : AppColors.neoBlack,
        ),
        shape: const NeoCardBorder(
          side: BorderSide(color: Color(0xFF000000), width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(4)),
          shadowOffset: Offset(2, 2),
          shadowColor: Color(0xFF000000),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        shape: Border(
          top: BorderSide(
            color: borderColor,
            width: 2.5,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.neoYellow : AppColors.neoBlack,
        contentTextStyle: _fontStyle(
          color: isDark ? AppColors.neoBlack : AppColors.neoWhite,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        shape: NeoCardBorder(
          side: const BorderSide(color: Color(0xFF000000), width: 2.0),
          borderRadius: BorderRadius.circular(4),
          shadowOffset: const Offset(3, 3),
          shadowColor: const Color(0xFF000000),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF444444) : const Color(0xFF000000),
        thickness: 2.0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF222222) : const Color(0xFFFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: borderColor, width: 2.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF888888) : const Color(0xFF000000),
            width: 2.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.neoYellow, width: 3.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: _fontStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFAAAAAA) : const Color(0xFF444444),
        ),
        hintStyle: _fontStyle(
          fontSize: 12,
          color: const Color(0xFF888888),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        shape: NeoCardBorder(
          side: BorderSide(color: borderColor, width: 2.5),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          shadowOffset: const Offset(5, 5),
          shadowColor: const Color(0xFF000000),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.neoBlack;
          }
          return const Color(0xFF888888);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.neoYellow;
          }
          return isDark ? const Color(0xFF444444) : const Color(0xFFDDDDDD);
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return const Color(0xFFCCCCCC);
            return AppColors.neoYellow;
          }),
          foregroundColor: WidgetStateProperty.all(const Color(0xFF000000)),
          shape: WidgetStateProperty.resolveWith((states) {
            final isPressed = states.contains(WidgetState.pressed);
            return NeoCardBorder(
              side: const BorderSide(color: Color(0xFF000000), width: 2.5),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              shadowOffset: isPressed ? const Offset(1, 1) : const Offset(3.5, 3.5),
              shadowColor: const Color(0xFF000000),
            );
          }),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          textStyle: WidgetStateProperty.all(
            _fontStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(
            isDark ? AppColors.neoWhite : const Color(0xFF000000),
          ),
          shape: WidgetStateProperty.resolveWith((states) {
            final isPressed = states.contains(WidgetState.pressed);
            return NeoCardBorder(
              side: BorderSide(
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                width: 2.5,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              shadowOffset: isPressed ? const Offset(1, 1) : const Offset(3.5, 3.5),
              shadowColor: const Color(0xFF000000),
            );
          }),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          textStyle: WidgetStateProperty.all(
            _fontStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return const Color(0xFFCCCCCC);
            return AppColors.neoYellow;
          }),
          foregroundColor: WidgetStateProperty.all(const Color(0xFF000000)),
          shape: WidgetStateProperty.resolveWith((states) {
            final isPressed = states.contains(WidgetState.pressed);
            return NeoCardBorder(
              side: const BorderSide(color: Color(0xFF000000), width: 2.5),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              shadowOffset: isPressed ? const Offset(1, 1) : const Offset(3.5, 3.5),
              shadowColor: const Color(0xFF000000),
            );
          }),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          textStyle: WidgetStateProperty.all(
            _fontStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? AppColors.neoWhite : AppColors.neoBlack,
          textStyle: _fontStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.all(
            const BorderSide(color: Color(0xFF000000), width: 2.0),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.neoYellow;
            }
            return isDark ? const Color(0xFF222222) : const Color(0xFFFFFFFF);
          }),
          foregroundColor: WidgetStateProperty.all(const Color(0xFF000000)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        side: const BorderSide(color: Color(0xFF000000), width: 2.0),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.neoYellow;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFF000000)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }

  // ─── RAW SKETCHBOOK THEME BUILDER ────────────────────────────────────────

  static ThemeData _buildRawTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    if (isDark) {
      return _buildRawDarkTheme();
    } else {
      return _buildRawLightTheme();
    }
  }

  static ThemeData _buildRawDarkTheme() {
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
      textTheme: _rawTextTheme(AppColors.paperWhite),
      extensions: const [
        AppThemeExtension(
          style: AppThemeStyle.rawSketchbook,
          primaryAccent: AppColors.primary,
          secondaryAccent: AppColors.secondary,
          tertiaryAccent: AppColors.tertiary,
          warningAccent: AppColors.warning,
          borderStroke: Color(0xFF3A3A3A),
          cardSurface: AppColors.cardDark,
          shadowOffset: Offset.zero,
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.paperWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: _fontStyle(
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
            return _fontStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.paperWhite,
              letterSpacing: 0.5,
            );
          }
          return _fontStyle(
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
        labelStyle: _fontStyle(
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
        contentTextStyle: _fontStyle(
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
        labelStyle: _fontStyle(
          fontSize: 12,
          color: const Color(0xFF888888),
        ),
        hintStyle: _fontStyle(
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
          textStyle: _fontStyle(
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
          textStyle: _fontStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.paperWhite,
          textStyle: _fontStyle(
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

  static ThemeData _buildRawLightTheme() {
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
      textTheme: _rawTextTheme(AppColors.markerBlack),
      extensions: const [
        AppThemeExtension(
          style: AppThemeStyle.rawSketchbook,
          primaryAccent: AppColors.primary,
          secondaryAccent: AppColors.secondary,
          tertiaryAccent: AppColors.tertiary,
          warningAccent: AppColors.warning,
          borderStroke: AppColors.lightBorder,
          cardSurface: AppColors.lightCardBg,
          shadowOffset: Offset.zero,
        ),
      ],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.lightPaperScaffold,
        foregroundColor: AppColors.markerBlack,
        titleTextStyle: _fontStyle(
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
            return _fontStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.markerBlack,
              letterSpacing: 0.5,
            );
          }
          return _fontStyle(
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
        labelStyle: _fontStyle(
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
        contentTextStyle: _fontStyle(
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
        labelStyle: _fontStyle(
          fontSize: 12,
          color: const Color(0xFF666666),
        ),
        hintStyle: _fontStyle(
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
          textStyle: _fontStyle(
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
          textStyle: _fontStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.markerBlack,
          textStyle: _fontStyle(
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

  // ─── TYPOGRAPHY ──────────────────────────────────────────────────────────

  static TextTheme _neoTextTheme(Color defaultTextColor) => TextTheme(
        displayLarge: _fontStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          letterSpacing: -2,
          color: defaultTextColor,
        ),
        displayMedium: _fontStyle(
          fontSize: 38,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
          color: defaultTextColor,
        ),
        displaySmall: _fontStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
          color: defaultTextColor,
        ),
        headlineLarge: _fontStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          color: defaultTextColor,
        ),
        headlineMedium: _fontStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: defaultTextColor,
        ),
        headlineSmall: _fontStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: defaultTextColor,
        ),
        titleLarge: _fontStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: defaultTextColor,
        ),
        titleMedium: _fontStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: defaultTextColor,
        ),
        titleSmall: _fontStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: defaultTextColor,
        ),
        bodyLarge: _fontStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: defaultTextColor,
        ),
        bodyMedium: _fontStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
          color: defaultTextColor,
        ),
        bodySmall: _fontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          color: defaultTextColor,
        ),
        labelLarge: _fontStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: defaultTextColor,
        ),
        labelMedium: _fontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: defaultTextColor,
        ),
        labelSmall: _fontStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: defaultTextColor,
        ),
      );

  static TextTheme _rawTextTheme(Color defaultTextColor) => TextTheme(
        displayLarge: _fontStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -2,
          color: defaultTextColor,
        ),
        displayMedium: _fontStyle(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          color: defaultTextColor,
        ),
        displaySmall: _fontStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: defaultTextColor,
        ),
        headlineLarge: _fontStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: defaultTextColor,
        ),
        headlineMedium: _fontStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: defaultTextColor,
        ),
        headlineSmall: _fontStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: defaultTextColor,
        ),
        titleLarge: _fontStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: defaultTextColor,
        ),
        titleMedium: _fontStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: defaultTextColor,
        ),
        titleSmall: _fontStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: defaultTextColor,
        ),
        bodyLarge: _fontStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: defaultTextColor,
        ),
        bodyMedium: _fontStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: defaultTextColor,
        ),
        bodySmall: _fontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          color: defaultTextColor,
        ),
        labelLarge: _fontStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: defaultTextColor,
        ),
        labelMedium: _fontStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: defaultTextColor,
        ),
        labelSmall: _fontStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: defaultTextColor,
        ),
      );
}

