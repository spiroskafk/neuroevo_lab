import 'dart:ui';
import 'package:flutter/material.dart';

class Bird {
  final int id;
  double x;
  double y;
  double velocity = 0;
  bool alive = true;
  int fitness = 0;

  static const double gravity = 800;
  static const double flapVelocity = -250;
  static const double radius = 12;
  static const double startX = 100;

  Bird({required this.id, required double screenHeight})
      : x = startX,
        y = screenHeight / 2;

  void flap() {
    velocity = flapVelocity;
  }

  void update(double dt, double screenHeight) {
    if (!alive) return;
    velocity += gravity * dt;
    y += velocity * dt;
    if (y - radius < 0 || y + radius > screenHeight) {
      alive = false;
    }
  }

  Rect get rect => Rect.fromCenter(center: Offset(x, y), width: radius * 2, height: radius * 2);
}
