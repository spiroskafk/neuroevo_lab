import 'dart:math';
import 'package:flutter/material.dart';

class Pipe {
  double x;
  final double gapCenter;
  final double gapSize;
  final double width;
  final double screenHeight;
  bool scored = false;

  static const double speed = 200;
  static const double gap = 150;

  static const double margin = 60;

  Pipe({
    required this.x,
    required this.screenHeight,
    Random? rng,
  })  : gapCenter = margin + gap / 2 + (rng ?? Random()).nextDouble() * (screenHeight - margin * 2 - gap),
        gapSize = gap,
        width = 60;

  void update(double dt) {
    x -= speed * dt;
  }

  bool get isOffScreen => x + width < 0;

  Rect get topRect => Rect.fromLTWH(x, 0, width, gapCenter - gapSize / 2);
  Rect get bottomRect => Rect.fromLTWH(x, gapCenter + gapSize / 2, width, screenHeight - (gapCenter + gapSize / 2));

  bool collides(Rect birdRect) {
    return topRect.overlaps(birdRect) || bottomRect.overlaps(birdRect);
  }
}
