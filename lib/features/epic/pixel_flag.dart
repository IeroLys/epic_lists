import 'package:flutter/material.dart';

/// Simple pixel-art flag of fixed shape.
/// The fill color is fully customizable.
class PixelFlag extends StatelessWidget {
  final Color color;
  final double size;

  const PixelFlag({
    super.key,
    required this.color,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PixelFlagPainter(color),
    );
  }
}

class _PixelFlagPainter extends CustomPainter {
  final Color color;

  _PixelFlagPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final unit = size.width / 8; // 8×8 grid

    // Pole (dark grey)
    paint.color = const Color(0xFF424242);
    canvas.drawRect(Rect.fromLTWH(unit * 0.5, unit * 0.5, unit * 0.9, unit * 7), paint);

    // Flag body – classic rectangular flag with a small triangular notch feel
    // We draw it as a set of filled rectangles for pure pixel look.
    paint.color = color;

    // Main rectangle of the flag
    canvas.drawRect(
      Rect.fromLTWH(unit * 1.5, unit * 0.8, unit * 5.5, unit * 3.6),
      paint,
    );

    // Small "wave" / pixel cut on the right edge for a classic flag silhouette
    paint.color = Colors.transparent; // we just leave the right side solid for simplicity
    // Alternative: draw a second darker shade for depth
    paint.color = Color.lerp(color, Colors.black, 0.18)!;
    canvas.drawRect(
      Rect.fromLTWH(unit * 5.5, unit * 0.8, unit * 1.5, unit * 1.2),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(unit * 5.5, unit * 2.6, unit * 1.5, unit * 1.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PixelFlagPainter oldDelegate) =>
      oldDelegate.color != color;
}
