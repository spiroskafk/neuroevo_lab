import 'package:flutter/material.dart';
import 'bird.dart';
import 'pipe.dart';

class FlappyPainter {
  static void drawBackground(Canvas canvas, Size size) {
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    final groundPaint = Paint()..color = const Color(0xFF8B4513);
    final grassPaint = Paint()..color = const Color(0xFF228B22);
    final groundH = 40.0;
    canvas.drawRect(Rect.fromLTWH(0, size.height - groundH, size.width, groundH), groundPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height - groundH - 4, size.width, 4), grassPaint);
  }

  static void drawBird(Canvas canvas, Bird bird) {
    final paint = Paint()..color = bird.alive ? const Color(0xFFFFD700) : Colors.grey;
    canvas.drawCircle(Offset(bird.x, bird.y), Bird.radius, paint);

    final border = Paint()
      ..color = const Color(0xFFB8860B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(bird.x, bird.y), Bird.radius, border);
  }

  static void drawPipes(Canvas canvas, List<Pipe> pipes) {
    for (final pipe in pipes) {
      final bodyPaint = Paint()..color = const Color(0xFF2E7D32);
      final capPaint = Paint()..color = const Color(0xFF4CAF50);

      canvas.drawRect(pipe.topRect, bodyPaint);
      canvas.drawRect(
        Rect.fromLTWH(pipe.x - 4, pipe.topRect.bottom - 20, pipe.width + 8, 20),
        capPaint,
      );

      canvas.drawRect(pipe.bottomRect, bodyPaint);
      canvas.drawRect(
        Rect.fromLTWH(pipe.x - 4, pipe.bottomRect.top, pipe.width + 8, 20),
        capPaint,
      );
    }
  }
}
