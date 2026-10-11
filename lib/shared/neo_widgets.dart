/// Neo-brutalist UI widgets and decoration helpers.
/// Solid black borders, hard zero-blur drop shadows, hyper-saturated pops.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bachelor_buddy/core/theme/app_theme.dart';

/// Returns a Neo-brutalist [BoxDecoration] with hard zero-blur drop shadow.
BoxDecoration neoBoxDecoration({
  Color color = Colors.white,
  Color borderColor = const Color(0xFF000000),
  double borderWidth = 2.5,
  double radius = 6.0,
  Offset shadowOffset = const Offset(3.5, 3.5),
  Color shadowColor = const Color(0xFF000000),
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor, width: borderWidth),
    boxShadow: shadowOffset == Offset.zero
        ? null
        : [
            BoxShadow(
              color: shadowColor,
              offset: shadowOffset,
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
  );
}

/// A Neo-brutalist container card with hard offset shadow and thick border.
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.borderWidth = 2.5,
    this.radius = 6.0,
    this.shadowOffset = const Offset(3.5, 3.5),
    this.shadowColor,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
    this.onTap,
  });

  final Widget child;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final Offset shadowOffset;
  final Color? shadowColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? AppColors.neoCardDark : AppColors.neoWhite);
    final border = borderColor ??
        (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000));
    final shadow = shadowColor ?? const Color(0xFF000000);

    Widget content = Container(
      padding: padding,
      decoration: neoBoxDecoration(
        color: bg,
        borderColor: border,
        borderWidth: borderWidth,
        radius: radius,
        shadowOffset: shadowOffset,
        shadowColor: shadow,
      ),
      child: child,
    );

    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    if (margin != EdgeInsets.zero) {
      content = Padding(padding: margin, child: content);
    }

    return content;
  }
}

/// A compact Neo-brutalist badge / tag with solid border.
class NeoBadge extends StatelessWidget {
  const NeoBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.neoYellow,
    this.textColor = AppColors.neoBlack,
    this.borderColor = const Color(0xFF000000),
    this.icon,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF000000),
            offset: Offset(2.0, 2.0),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4.0),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceMono(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// A tactile Neo-brutalist interactive button that depresses on tap.
class NeoButton extends StatefulWidget {
  const NeoButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = AppColors.neoYellow,
    this.borderColor = const Color(0xFF000000),
    this.shadowColor = const Color(0xFF000000),
    this.radius = 6.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
  });

  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color borderColor;
  final Color shadowColor;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final offset = _isPressed ? const Offset(1.0, 1.0) : const Offset(3.5, 3.5);

    return GestureDetector(
      onTapDown: widget.onPressed == null
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.onPressed == null
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        padding: widget.padding,
        transform: Matrix4.translationValues(
          _isPressed ? 2.5 : 0.0,
          _isPressed ? 2.5 : 0.0,
          0.0,
        ),
        decoration: neoBoxDecoration(
          color: widget.color,
          borderColor: widget.borderColor,
          borderWidth: 2.5,
          radius: widget.radius,
          shadowOffset: offset,
          shadowColor: widget.shadowColor,
        ),
        child: widget.child,
      ),
    );
  }
}
