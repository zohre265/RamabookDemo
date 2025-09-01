import 'package:flutter/material.dart';
import 'dart:math' as math;

/// کلاس StarryPainter برای بک‌گراند ستاره‌ای و حرکت شهاب‌ها
class StarryPainter extends CustomPainter {
  final double progress;

  StarryPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // پس‌زمینه گرادیانت
    final bg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0b1023), Color(0xFF0e1b3c), Color(0xFF142a5b)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, bg);

    // رسم ستاره‌ها
    final starPaint = Paint()..color = Colors.white.withOpacity(0.9);
    for (int i = 0; i < 220; i++) {
      final x = (i * 123.45) % size.width;
      final y = (i * 89.32) % size.height;
      final twinkle = 0.6 + 0.4 * math.sin(progress * 2 * math.pi + i);
      canvas.drawCircle(Offset(x, y), twinkle * 0.9 + 0.3, starPaint);
    }

    // رسم شهاب‌ها
    final cometPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (int c = 0; c < 3; c++) {
      final t = (progress + c / 3) % 1.0;
      final start = Offset(size.width * (1 - t), size.height * (0.15 + 0.25 * c));
      final end = start + const Offset(-120, 40);
      cometPaint.strokeWidth = 2;
      cometPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawLine(start, end, cometPaint);
    }

    // رسم خطوط مارپیچی تزئینی
    final swirl = Paint()
      ..color = const Color(0x22ffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (double r = 18; r < 120; r += 12) {
      final path = Path();
      for (double a = 0; a < math.pi * 2; a += 0.2) {
        final rr = r + 4 * math.sin(a * 3 + progress * 6.28);
        final x = size.width * 0.78 + rr * math.cos(a);
        final y = size.height * 0.28 + rr * math.sin(a);
        if (a == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, swirl);
    }
  }

  @override
  bool shouldRepaint(covariant StarryPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
