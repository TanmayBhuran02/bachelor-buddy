/// Neo-brutalism and Raw sketchbook aesthetic themes for Bachelor Buddy.
/// Supports both Neobrutalism (bold borders, hard offset drop shadows, punchy colors)
/// and Raw sketchbook with multiple color palettes (Botanical Sage, Blueprint Cyan, Sepia Walnut).
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Available aesthetic styles for the entire app.
enum AppThemeStyle {
  neobrutalism,
  rawSketchbook,
}

/// Available color palettes for the Raw Sketchbook style.
enum SketchbookPalette {
  botanical, // Sage & Terracotta (Field Notebook) - Default
  blueprint, // Cobalt & Cyan (Architect Studio)
  sepia,     // Walnut & Amber (Traveler's Journal)
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
    this.sketchbookPalette = SketchbookPalette.botanical,
  });

  final AppThemeStyle style;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color tertiaryAccent;
  final Color warningAccent;
  final Color borderStroke;
  final Color cardSurface;
  final Offset shadowOffset;
  final SketchbookPalette sketchbookPalette;

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
    SketchbookPalette? sketchbookPalette,
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
      sketchbookPalette: sketchbookPalette ?? this.sketchbookPalette,
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
      sketchbookPalette:
          t < 0.5 ? sketchbookPalette : other.sketchbookPalette,
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

/// Palette tokens for Sketchbook themes across light and dark modes.
class _SketchbookTokens {
  final Color scaffold;
  final Color card;
  final Color border;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color warning;
  final Color surfaceContainer;
  final Color track;
  final Color text;
  final Color textMuted;

  const _SketchbookTokens({
    required this.scaffold,
    required this.card,
    required this.border,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.warning,
    required this.surfaceContainer,
    required this.track,
    required this.text,
    required this.textMuted,
  });

  static _SketchbookTokens get(SketchbookPalette palette, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (palette) {
      case SketchbookPalette.botanical:
        return isDark
            ? const _SketchbookTokens(
                scaffold: Color(0xFF131915),
                card: Color(0xFF1A221C),
                border: Color(0xFFC7C0B5),
                primary: Color(0xFF7EAA8B),
                secondary: Color(0xFFE07A5F),
                tertiary: Color(0xFFE06D5E),
                warning: Color(0xFFE0B253),
                surfaceContainer: Color(0xFF1F2922),
                track: Color(0xFF28352C),
                text: Color(0xFFF4F1EA),
                textMuted: Color(0xFFA5B0A8),
              )
            : const _SketchbookTokens(
                scaffold: Color(0xFFF4F1EA),
                card: Color(0xFFFAF7F0),
                border: Color(0xFF1E2B20),
                primary: Color(0xFF4E7A57),
                secondary: Color(0xFFB85D43),
                tertiary: Color(0xFFC45142),
                warning: Color(0xFFC99738),
                surfaceContainer: Color(0xFFE8E4DA),
                track: Color(0xFFDDD8CC),
                text: Color(0xFF1E2B20),
                textMuted: Color(0xFF5A665C),
              );

      case SketchbookPalette.blueprint:
        return isDark
            ? const _SketchbookTokens(
                scaffold: Color(0xFF0D1520),
                card: Color(0xFF152030),
                border: Color(0xFFC8DBF8),
                primary: Color(0xFF5C8FF7),
                secondary: Color(0xFF2DD4BF),
                tertiary: Color(0xFFF87171),
                warning: Color(0xFFFBBF24),
                surfaceContainer: Color(0xFF1B293E),
                track: Color(0xFF22334D),
                text: Color(0xFFF0F5FD),
                textMuted: Color(0xFF94A9C9),
              )
            : const _SketchbookTokens(
                scaffold: Color(0xFFEDF2F7),
                card: Color(0xFFF7FAFC),
                border: Color(0xFF1A2536),
                primary: Color(0xFF2B59C3),
                secondary: Color(0xFF0098A6),
                tertiary: Color(0xFFD9534F),
                warning: Color(0xFFD98E04),
                surfaceContainer: Color(0xFFDFE7EF),
                track: Color(0xFFCFDCE8),
                text: Color(0xFF1A2536),
                textMuted: Color(0xFF536275),
              );

      case SketchbookPalette.sepia:
        return isDark
            ? const _SketchbookTokens(
                scaffold: Color(0xFF181310),
                card: Color(0xFF221C18),
                border: Color(0xFFE2D6CB),
                primary: Color(0xFFBFA08A),
                secondary: Color(0xFF8AA87A),
                tertiary: Color(0xFFD4685D),
                warning: Color(0xFFE6A862),
                surfaceContainer: Color(0xFF2B231E),
                track: Color(0xFF362C26),
                text: Color(0xFFF5EFEB),
                textMuted: Color(0xFFAFA096),
              )
            : const _SketchbookTokens(
                scaffold: Color(0xFFF5EFEB),
                card: Color(0xFFFAF6F2),
                border: Color(0xFF2A211B),
                primary: Color(0xFF7D5A44),
                secondary: Color(0xFF586B4D),
                tertiary: Color(0xFFA6443B),
                warning: Color(0xFFC07D38),
                surfaceContainer: Color(0xFFEBE3DC),
                track: Color(0xFFDED4CB),
                text: Color(0xFF2A211B),
                textMuted: Color(0xFF6B5C52),
              );
    }
  }
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

  // Default / fallback palette
  static const primary = Color(0xFF4E7A57);
  static const secondary = Color(0xFFB85D43);
  static const tertiary = Color(0xFFC45142);
  static const warning = Color(0xFFC99738);

  static const budgetGreen = Color(0xFF4A8A4E);
  static const budgetAmber = Color(0xFFB89545);
  static const budgetRed = Color(0xFFC45B4A);

  static const paperWhite = Color(0xFFFAFAF8);
  static const markerBlack = Color(0xFF1A1A1A);
  static const kraftBrown = Color(0xFFC4A77D);

  static AppThemeStyle styleOf(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.style ??
      AppThemeStyle.neobrutalism;

  static SketchbookPalette sketchbookPaletteOf(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.sketchbookPalette ??
      SketchbookPalette.botanical;

  static Color primaryOf(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.primaryAccent ?? primary;

  static Color secondaryOf(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.secondaryAccent ?? secondary;

  static Color tertiaryOf(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.tertiaryAccent ?? tertiary;

  static Color warningOf(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()?.warningAccent ?? warning;

  /// Dedicated green shade for Tiffin Received across all aesthetic styles and palettes
  static Color tiffinReceived(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (ext?.style == AppThemeStyle.neobrutalism) {
      return isDark ? neoGreen : const Color(0xFF10B981);
    }
    final palette = ext?.sketchbookPalette ?? SketchbookPalette.botanical;
    switch (palette) {
      case SketchbookPalette.botanical:
        return isDark ? const Color(0xFF7EAA8B) : const Color(0xFF4E7A57);
      case SketchbookPalette.blueprint:
        return isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A);
      case SketchbookPalette.sepia:
        return isDark ? const Color(0xFF8AA87A) : const Color(0xFF586B4D);
    }
  }

  // Dynamic context-aware helpers
  static Color text(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (ext?.style == AppThemeStyle.neobrutalism) {
      return isDark ? neoWhite : neoBlack;
    }
    return isDark ? const Color(0xFFF4F1EA) : (ext?.borderStroke ?? const Color(0xFF1E2B20));
  }

  static Color textMuted(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (ext?.style == AppThemeStyle.neobrutalism) {
      return isDark ? const Color(0xFFBBBBBB) : const Color(0xFF444444);
    }
    return isDark ? const Color(0xFFA5B0A8) : const Color(0xFF5A665C);
  }

  static Color textSubtle(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (ext?.style == AppThemeStyle.neobrutalism) {
      return isDark ? const Color(0xFF888888) : const Color(0xFF666666);
    }
    return isDark ? const Color(0xFF7A857D) : const Color(0xFF7A877E);
  }

  static Color border(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>();
    if (ext != null) return ext.borderStroke;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  static Color surface(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>();
    if (ext?.style == AppThemeStyle.neobrutalism) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return isDark ? neoSurfaceDark : neoSurfaceLight;
    }
    return Theme.of(context).colorScheme.surfaceContainer;
  }

  static Color track(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>();
    if (ext?.style == AppThemeStyle.neobrutalism) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return isDark ? neoTrackDark : neoTrackLight;
    }
    return Theme.of(context).colorScheme.surfaceContainerHigh;
  }

  static Color card(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>();
    if (ext != null) return ext.cardSurface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? neoCardDark : neoWhite;
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

  static ThemeData getLightTheme([
    AppThemeStyle style = AppThemeStyle.neobrutalism,
    SketchbookPalette palette = SketchbookPalette.botanical,
  ]) {
    return style == AppThemeStyle.neobrutalism
        ? _buildNeobrutalismTheme(brightness: Brightness.light)
        : _buildRawTheme(brightness: Brightness.light, palette: palette);
  }

  static ThemeData getDarkTheme([
    AppThemeStyle style = AppThemeStyle.neobrutalism,
    SketchbookPalette palette = SketchbookPalette.botanical,
  ]) {
    return style == AppThemeStyle.neobrutalism
        ? _buildNeobrutalismTheme(brightness: Brightness.dark)
        : _buildRawTheme(brightness: Brightness.dark, palette: palette);
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

  static ThemeData _buildRawTheme({
    required Brightness brightness,
    SketchbookPalette palette = SketchbookPalette.botanical,
  }) {
    final colors = _SketchbookTokens.get(palette, brightness);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.card,
      secondary: colors.secondary,
      onSecondary: colors.card,
      tertiary: colors.tertiary,
      onTertiary: colors.card,
      error: colors.tertiary,
      onError: colors.card,
      surface: colors.scaffold,
      onSurface: colors.text,
      surfaceContainerLowest: colors.scaffold,
      surfaceContainerLow: colors.surfaceContainer,
      surfaceContainer: colors.surfaceContainer,
      surfaceContainerHigh: colors.track,
      surfaceContainerHighest: colors.track,
      outline: colors.border,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: colors.scaffold,
      textTheme: _rawTextTheme(colors.text),
      extensions: [
        AppThemeExtension(
          style: AppThemeStyle.rawSketchbook,
          primaryAccent: colors.primary,
          secondaryAccent: colors.secondary,
          tertiaryAccent: colors.tertiary,
          warningAccent: colors.warning,
          borderStroke: colors.border,
          cardSurface: colors.card,
          shadowOffset: Offset.zero,
          sketchbookPalette: palette,
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.scaffold,
        foregroundColor: colors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: _fontStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.text,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RawCardBorder(
          side: BorderSide(
            color: colors.border,
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.scaffold,
        indicatorColor: colors.primary.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _fontStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.text,
              letterSpacing: 0.5,
            );
          }
          return _fontStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: colors.textMuted,
            letterSpacing: 0.5,
          );
        }),
        height: 64,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.text,
        foregroundColor: colors.card,
        elevation: 0,
        shape: RawCardBorder(
          side: BorderSide(
            color: colors.border,
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainer,
        labelStyle: _fontStyle(
          fontSize: 11,
          letterSpacing: 0.3,
          color: colors.text,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        side: BorderSide(color: colors.border, width: 1.2),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.text,
        contentTextStyle: _fontStyle(
          color: colors.card,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: colors.border.withValues(alpha: 0.3),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colors.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colors.text, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: _fontStyle(
          fontSize: 12,
          color: colors.textMuted,
        ),
        hintStyle: _fontStyle(
          fontSize: 12,
          color: colors.textMuted.withValues(alpha: 0.7),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        shape: RawCardBorder(
          side: BorderSide(color: colors.border, width: 1.5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.text;
          }
          return colors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withValues(alpha: 0.4);
          }
          return colors.surfaceContainer;
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.text,
          foregroundColor: colors.card,
          shape: RawCardBorder(
            side: BorderSide(color: colors.border, width: 1.5),
          ),
          textStyle: _fontStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.text,
          foregroundColor: colors.card,
          shape: RawCardBorder(
            side: BorderSide(color: colors.border, width: 1.5),
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
          foregroundColor: colors.text,
          side: BorderSide(color: colors.border, width: 1.5),
          shape: RawCardBorder(
            side: BorderSide(color: colors.border, width: 1.5),
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
          foregroundColor: colors.text,
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
        side: BorderSide(color: colors.border, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.text;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colors.card),
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
