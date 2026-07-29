import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'creature.dart';
import 'world.dart';

class PredatorPreyPainter {
  static void drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF1B3A1B);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF4A7C4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(
        World.margin, World.margin,
        size.width - World.margin * 2, size.height - World.margin * 2,
      ),
      borderPaint,
    );
  }

  static void drawFoods(Canvas canvas, List<Food> foods) {
    final paint = Paint()..color = const Color(0xFF66BB6A);
    for (final f in foods) {
      if (!f.eaten) {
        canvas.drawCircle(Offset(f.x, f.y), World.foodRadius, paint);
      }
    }
  }

  static void drawCreature(Canvas canvas, Creature c) {
    if (!c.alive) return;

    final color = c.type == CreatureType.predator
        ? const Color(0xFFE53935)
        : const Color(0xFF43A047);

    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(c.x, c.y), c.radius, paint);

    if (c.dx != 0 || c.dy != 0) {
      final angle = math.atan2(c.dy, c.dx);
      final lineEnd = Offset(
        c.x + math.cos(angle) * c.radius * 1.5,
        c.y + math.sin(angle) * c.radius * 1.5,
      );
      final dirPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(c.x, c.y), lineEnd, dirPaint);
    }

    _drawEnergyBar(canvas, c);
  }

  static void _drawEnergyBar(Canvas canvas, Creature c) {
    final barWidth = c.radius * 2.5;
    final barHeight = 3.0;
    final barX = c.x - barWidth / 2;
    final barY = c.y - c.radius - 8;

    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawRect(Rect.fromLTWH(barX, barY, barWidth, barHeight), bgPaint);

    final ratio = (c.energy / Creature.maxEnergy).clamp(0.0, 1.0);
    final energyColor = Color.lerp(Colors.red, Colors.green, ratio)!;
    canvas.drawRect(
      Rect.fromLTWH(barX, barY, barWidth * ratio, barHeight),
      Paint()..color = energyColor,
    );
  }
}
