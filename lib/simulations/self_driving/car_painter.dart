import 'dart:math';
import 'package:flutter/material.dart';
import 'car.dart';
import 'track.dart';

class CarPainter {
  static void drawTrack(Canvas canvas, Track track) {
    final trackPaint = Paint()
      ..color = const Color(0xFF555555)
      ..style = PaintingStyle.fill;

    final path = Path();
    if (track.innerPoints.isNotEmpty) {
      path.moveTo(track.outerPoints[0].dx, track.outerPoints[0].dy);
      for (int i = 1; i < track.outerPoints.length; i++) {
        path.lineTo(track.outerPoints[i].dx, track.outerPoints[i].dy);
      }
      path.close();

      path.moveTo(track.innerPoints[0].dx, track.innerPoints[0].dy);
      for (int i = track.innerPoints.length - 1; i >= 0; i--) {
        path.lineTo(track.innerPoints[i].dx, track.innerPoints[i].dy);
      }
      path.close();
    }
    canvas.drawPath(path, trackPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final innerPath = Path()..moveTo(track.innerPoints[0].dx, track.innerPoints[0].dy);
    for (int i = 1; i < track.innerPoints.length; i++) {
      innerPath.lineTo(track.innerPoints[i].dx, track.innerPoints[i].dy);
    }
    innerPath.close();
    canvas.drawPath(innerPath, borderPaint);

    final outerPath = Path()..moveTo(track.outerPoints[0].dx, track.outerPoints[0].dy);
    for (int i = 1; i < track.outerPoints.length; i++) {
      outerPath.lineTo(track.outerPoints[i].dx, track.outerPoints[i].dy);
    }
    outerPath.close();
    canvas.drawPath(outerPath, borderPaint);

    final startPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawCircle(track.startPoint, 6, startPaint);
  }

  static void drawCar(Canvas canvas, Car car, {required bool isBest}) {
    if (!car.alive) return;

    canvas.save();
    canvas.translate(car.x, car.y);
    canvas.rotate(car.angle);

    final carPaint = Paint()
      ..color = isBest ? const Color(0xFFFFD700) : const Color(0xFF2196F3)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: car.width,
      height: car.height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      carPaint,
    );

    if (isBest) {
      final glowPaint = Paint()
        ..color = const Color(0x44FFD700)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(4), const Radius.circular(5)),
        glowPaint,
      );
    }

    canvas.restore();
  }

  static void drawSensors(
    Canvas canvas, Car car, List<List<Offset>> trackSegments,
  ) {
    if (!car.alive) return;

    const sensorAngles = [-pi / 2, -pi / 4, 0, pi / 4, pi / 2];

    for (final sensorAngle in sensorAngles) {
      final rayAngle = car.angle + sensorAngle;
      double minDist = 200;

      for (final segment in trackSegments) {
        final intersection = _rayIntersectSegment(
          car.x, car.y, rayAngle,
          segment[0].dx, segment[0].dy,
          segment[1].dx, segment[1].dy,
        );
        if (intersection != null && intersection > 0 && intersection < minDist) {
          minDist = intersection;
        }
      }

      final endX = car.x + cos(rayAngle) * minDist;
      final endY = car.y + sin(rayAngle) * minDist;

      final sensorPaint = Paint()
        ..color = Color.lerp(
          const Color(0x66FF0000),
          const Color(0x6600FF00),
          1 - (minDist / 200),
        )!
        ..strokeWidth = 1;

      canvas.drawLine(Offset(car.x, car.y), Offset(endX, endY), sensorPaint);
    }
  }

  static double? _rayIntersectSegment(
    double rx, double ry, double rAngle,
    double x1, double y1, double x2, double y2,
  ) {
    final dx = cos(rAngle);
    final dy = sin(rAngle);
    final sdx = x2 - x1;
    final sdy = y2 - y1;

    final denom = dx * sdy - dy * sdx;
    if (denom.abs() < 1e-10) return null;

    final t = ((x1 - rx) * sdy - (y1 - ry) * sdx) / denom;
    final u = ((x1 - rx) * dy - (y1 - ry) * dx) / denom;

    if (t > 0 && u >= 0 && u <= 1) {
      return t;
    }
    return null;
  }
}
