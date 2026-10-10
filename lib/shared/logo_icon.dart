import 'package:flutter/material.dart';

class BachelorBuddyLogoIcon extends StatelessWidget {
  final double size;

  const BachelorBuddyLogoIcon({
    super.key,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BachelorBuddyLogoPainter(),
    );
  }
}

class _BachelorBuddyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / 512.0) * 0.75; // Shrunk by 25% for comfortable breathing room

    // Background dark container
    final bgPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.18),
    );
    canvas.drawRRect(rrect, bgPaint);

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale, scale);

    // House silhouette in warm cream
    final housePaint = Paint()
      ..color = const Color(0xFFFFFEEF)
      ..style = PaintingStyle.fill;

    final housePath = Path()
      ..moveTo(0, -140)
      ..lineTo(140, -20)
      ..lineTo(140, 115)
      ..cubicTo(140, 128.8, 128.8, 140, 115, 140)
      ..lineTo(-115, 140)
      ..cubicTo(-128.8, 140, -140, 128.8, -140, 115)
      ..lineTo(-140, -20)
      ..close();

    canvas.drawPath(housePath, housePaint);

    // Negative space cutouts in #1A1A1A
    final cutoutPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;

    // Top bowl of B
    final topBPath = Path()
      ..moveTo(-70, -20)
      ..lineTo(28, -20)
      ..cubicTo(56, -20, 74, -5, 74, 16)
      ..cubicTo(74, 37, 56, 52, 28, 52)
      ..lineTo(-70, 52)
      ..close()
      ..moveTo(-32, 6)
      ..lineTo(18, 6)
      ..cubicTo(31, 6, 40, 11, 40, 16)
      ..cubicTo(40, 21, 31, 26, 18, 26)
      ..lineTo(-32, 26)
      ..close();
    topBPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(topBPath, cutoutPaint);

    // Bottom bowl of B + doorway cutout
    final bottomBPath = Path()
      ..moveTo(-70, 60)
      ..lineTo(38, 60)
      ..cubicTo(68, 60, 88, 77, 88, 100)
      ..cubicTo(88, 123, 68, 140, 38, 140)
      ..lineTo(-70, 140)
      ..close()
      ..moveTo(-32, 87)
      ..lineTo(24, 87)
      ..cubicTo(39, 87, 50, 93, 50, 100)
      ..cubicTo(50, 107, 39, 113, 24, 113)
      ..lineTo(-32, 113)
      ..close();
    bottomBPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(bottomBPath, cutoutPaint);

    // Chimney cutout
    final chimney = RRect.fromRectAndRadius(
      const Rect.fromLTWH(52, -115, 26, 42),
      const Radius.circular(3),
    );
    canvas.drawRRect(chimney, cutoutPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
