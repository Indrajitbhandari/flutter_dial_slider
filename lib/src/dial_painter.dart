import 'dart:math';
import 'package:flutter/material.dart';

class DialPainter extends CustomPainter {
  final int minValue;
  final int startIndex;
  final double subOffset;
  final int visibleCount;
  final int totalValues;

  DialPainter({
    required this.minValue,
    required this.startIndex,
    required this.subOffset,
    required this.visibleCount,
    required this.totalValues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final outerRect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()..color = const Color.fromARGB(255, 239, 76, 133);
    canvas.drawArc(outerRect, pi, pi, true, bgPaint);

    final borderPaint = Paint()
      ..color = const Color.fromARGB(255, 239, 246, 248).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawArc(outerRect, pi, pi, false, borderPaint);

    final innerRadius = radius * .67;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    final innerPaint = Paint()..color = Colors.white;
    canvas.drawArc(innerRect, pi, pi, true, innerPaint);

    canvas.drawArc(
      innerRect,
      pi,
      pi,
      false,
      Paint()
        ..color = const Color(0xFFE6E7E8)
        ..style = PaintingStyle.stroke,
    );
    drawNumbers(canvas, center, radius * .9);

    drawTicks(canvas, center, radius * .8);
  }

  void drawTicks(Canvas canvas, Offset c, double r) {
    final step = pi / (visibleCount - 1);

    final normalPaint = Paint()
      ..color = Color.fromARGB(255, 246, 246, 246)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < visibleCount; i++) {
      final value = startIndex + i;
      if (value < 0 || value >= totalValues) continue;

      final angle = pi + (i - subOffset) * step;

      // 🔥 SAME bottom logic as numbers
      double verticalShift = 0;
      if (sin(angle) > -0.12) {
        verticalShift = -10; // MUST match drawNumbers
      }

      final start = Offset(
        c.dx + cos(angle) * (r - 14),
        c.dy + sin(angle) * (r - 14) + verticalShift,
      );

      final end = Offset(
        c.dx + cos(angle) * r,
        c.dy + sin(angle) * r + verticalShift,
      );

      canvas.drawLine(start, end, normalPaint);
    }
  }

  void drawNumbers(Canvas canvas, Offset c, double r) {
    final step = pi / (visibleCount - 1);

    for (int i = 0; i < visibleCount; i++) {
      final value = startIndex + i;
      if (value < 0 || value >= totalValues) continue;

      final angle = pi + (i - subOffset) * step;

      // Base position
      Offset pos = Offset(c.dx + cos(angle) * r, c.dy + sin(angle) * r);

      // 🔥 Bottom padding fix
      final bool isNearBottom = sin(angle) > -0.15;
      if (isNearBottom) {
        pos = pos.translate(0, -10); // 👈 adjust (8–14 works well)
      }

      final isCenter = (i - subOffset - visibleCount ~/ 2).abs() < 0.5;

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${minValue + value}',
          style: TextStyle(
            fontSize: isCenter ? 20 : 16,
            fontWeight: isCenter ? FontWeight.bold : FontWeight.w500,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset =
          pos - Offset(textPainter.width / 2, textPainter.height / 2);

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant DialPainter old) =>
      old.startIndex != startIndex || old.subOffset != subOffset;
}
