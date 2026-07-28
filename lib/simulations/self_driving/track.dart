import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/math_utils.dart';

class Track {
  final List<Offset> innerPoints;
  final List<Offset> outerPoints;
  final List<List<Offset>> segments;
  final double trackWidth;
  final Offset startPoint;
  final double startAngle;
  final Rect bounds;

  Track._({
    required this.innerPoints,
    required this.outerPoints,
    required this.segments,
    required this.trackWidth,
    required this.startPoint,
    required this.startAngle,
    required this.bounds,
  });

  factory Track.create(Size size, {double trackWidth = 40}) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = min(size.width, size.height) * 0.35;

    final points = <Offset>[];
    final numPoints = 30;
    for (int i = 0; i < numPoints; i++) {
      final t = 2 * pi * i / numPoints;
      final r = radius + sin(3 * t) * radius * 0.3;
      points.add(Offset(
        cx + r * cos(t),
        cy + r * sin(t),
      ));
    }

    final inner = <Offset>[];
    final outer = <Offset>[];
    final segs = <List<Offset>>[];

    for (int i = 0; i < points.length; i++) {
      final curr = points[i];
      final next = points[(i + 1) % points.length];

      final angle = MathUtils.angleBetween(curr.dx, curr.dy, next.dx, next.dy);
      final perpAngle = angle + pi / 2;

      inner.add(Offset(
        curr.dx + cos(perpAngle) * trackWidth / 2,
        curr.dy + sin(perpAngle) * trackWidth / 2,
      ));
      outer.add(Offset(
        curr.dx - cos(perpAngle) * trackWidth / 2,
        curr.dy - sin(perpAngle) * trackWidth / 2,
      ));

      segs.add([
        Offset(
          curr.dx + cos(perpAngle) * trackWidth / 2,
          curr.dy + sin(perpAngle) * trackWidth / 2,
        ),
        Offset(
          curr.dx - cos(perpAngle) * trackWidth / 2,
          curr.dy - sin(perpAngle) * trackWidth / 2,
        ),
      ]);
    }

    final allPoints = [...inner, ...outer];
    final minX = allPoints.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
    final minY = allPoints.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
    final maxX = allPoints.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
    final maxY = allPoints.map((p) => p.dy).reduce((a, b) => a > b ? a : b);

    final startAngle = MathUtils.angleBetween(
      points[0].dx, points[0].dy,
      points[1].dx, points[1].dy,
    );

    return Track._(
      innerPoints: inner,
      outerPoints: outer,
      segments: segs,
      trackWidth: trackWidth,
      startPoint: points[0],
      startAngle: startAngle,
      bounds: Rect.fromLTRB(minX - 20, minY - 20, maxX + 20, maxY + 20),
    );
  }

  bool isOnTrack(double x, double y) {
    for (final seg in segments) {
      final d = _pointToSegmentDistance(x, y, seg[0].dx, seg[0].dy, seg[1].dx, seg[1].dy);
      if (d < trackWidth / 2) return true;
    }
    return false;
  }

  double _pointToSegmentDistance(
    double px, double py,
    double x1, double y1, double x2, double y2,
  ) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final len2 = dx * dx + dy * dy;
    if (len2 == 0) return MathUtils.distance(px, py, x1, y1);

    double t = ((px - x1) * dx + (py - y1) * dy) / len2;
    t = t.clamp(0, 1);

    return MathUtils.distance(px, py, x1 + t * dx, y1 + t * dy);
  }
}
