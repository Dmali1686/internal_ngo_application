import 'package:flutter/material.dart';

/// Custom painter that draws a subtle repeating paw-print pattern.
/// Used for backgrounds across the app (Splash, Login, etc).
class PawPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.025)
      ..style = PaintingStyle.fill;

    const spacing = 60.0;
    const pawSize = 6.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        // Offset every other row for a more natural pattern
        final offsetX = (y ~/ spacing) % 2 == 0 ? 0.0 : spacing / 2;
        final cx = x + offsetX;

        // Main pad (larger circle)
        canvas.drawCircle(Offset(cx, y + pawSize * 1.5), pawSize * 1.2, paint);

        // Toe pads (4 smaller circles)
        canvas.drawCircle(
          Offset(cx - pawSize, y - pawSize * 0.3),
          pawSize * 0.6,
          paint,
        );
        canvas.drawCircle(
          Offset(cx + pawSize, y - pawSize * 0.3),
          pawSize * 0.6,
          paint,
        );
        canvas.drawCircle(
          Offset(cx - pawSize * 0.4, y - pawSize * 1.2),
          pawSize * 0.55,
          paint,
        );
        canvas.drawCircle(
          Offset(cx + pawSize * 0.4, y - pawSize * 1.2),
          pawSize * 0.55,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
