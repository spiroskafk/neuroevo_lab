import 'dart:math';
import 'creature.dart';

class Food {
  double x, y;
  bool eaten;

  Food({required this.x, required this.y}) : eaten = false;
}

class World {
  final double width;
  final double height;
  final List<Creature> predators;
  final List<Creature> prey;
  final List<Food> foods;
  final Random _rng;

  static const int foodCount = 60;
  static const double foodRadius = 3;
  static const double margin = 40;

  World({
    required this.width,
    required this.height,
    required this.predators,
    required this.prey,
    Random? rng,
  }) : foods = [],
       _rng = rng ?? Random() {
    _spawnFood(foodCount);
  }

  void _spawnFood(int count) {
    for (int i = 0; i < count; i++) {
      foods.add(Food(
        x: margin + _rng.nextDouble() * (width - margin * 2),
        y: margin + _rng.nextDouble() * (height - margin * 2),
      ));
    }
  }

  void refillFood() {
    foods.removeWhere((f) => f.eaten);
    final missing = foodCount - foods.length;
    if (missing > 0) _spawnFood(missing);
  }

  void clampToBounds(Creature c) {
    if (c.x < margin) { c.x = margin; c.dx = 0; }
    if (c.x > width - margin) { c.x = width - margin; c.dx = 0; }
    if (c.y < margin) { c.y = margin; c.dy = 0; }
    if (c.y > height - margin) { c.y = height - margin; c.dy = 0; }
  }

  Creature? nearestPrey(Creature predator) {
    Creature? nearest;
    double minDist = double.infinity;
    for (final p in prey) {
      if (!p.alive) continue;
      final d = _dist(predator.x, predator.y, p.x, p.y);
      if (d < minDist) { minDist = d; nearest = p; }
    }
    return nearest;
  }

  Creature? nearestPredator(Creature prey_) {
    Creature? nearest;
    double minDist = double.infinity;
    for (final p in predators) {
      if (!p.alive) continue;
      final d = _dist(prey_.x, prey_.y, p.x, p.y);
      if (d < minDist) { minDist = d; nearest = p; }
    }
    return nearest;
  }

  Food? nearestFood(Creature prey_) {
    Food? nearest;
    double minDist = double.infinity;
    for (final f in foods) {
      if (f.eaten) continue;
      final d = _dist(prey_.x, prey_.y, f.x, f.y);
      if (d < minDist) { minDist = d; nearest = f; }
    }
    return nearest;
  }

  void checkPredatorPreyCollisions() {
    for (final p in predators) {
      if (!p.alive) continue;
      for (final prey_ in prey) {
        if (!prey_.alive) continue;
        final d = _dist(p.x, p.y, prey_.x, prey_.y);
        if (d < p.radius + prey_.radius) {
          prey_.alive = false;
          p.energy = (p.energy + Creature.eatGain).clamp(0, Creature.maxEnergy);
          p.score++;
        }
      }
    }
  }

  void checkPreyFoodCollisions() {
    for (final prey_ in prey) {
      if (!prey_.alive) continue;
      for (final f in foods) {
        if (f.eaten) continue;
        final d = _dist(prey_.x, prey_.y, f.x, f.y);
        if (d < prey_.radius + foodRadius) {
          f.eaten = true;
          prey_.energy = (prey_.energy + Creature.foodGain).clamp(0, Creature.maxEnergy);
          prey_.score++;
        }
      }
    }
  }

  static double _dist(double x1, double y1, double x2, double y2) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return sqrt(dx * dx + dy * dy);
  }
}
