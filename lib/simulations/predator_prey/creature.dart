import 'dart:ui';

enum CreatureType { predator, prey }

class Creature {
  final int id;
  final CreatureType type;
  double x, y;
  double dx, dy;
  double energy;
  bool alive;
  int score;
  double age;

  static const double maxEnergy = 100;
  static const double predatorSpeed = 160;
  static const double preySpeed = 180;
  static const double predatorRadius = 10;
  static const double preyRadius = 7;
  static const double energyDrain = 5;
  static const double eatGain = 40;
  static const double foodGain = 25;

  Creature({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
  })  : dx = 0,
       dy = 0,
       energy = maxEnergy,
       alive = true,
       score = 0,
       age = 0;

  double get radius => type == CreatureType.predator ? predatorRadius : preyRadius;
  double get speed => type == CreatureType.predator ? predatorSpeed : preySpeed;

  void update(double dt) {
    if (!alive) return;
    x += dx * speed * dt;
    y += dy * speed * dt;
    energy -= energyDrain * dt;
    age += dt;
    if (energy <= 0) {
      alive = false;
      energy = 0;
    }
  }

  Rect get rect => Rect.fromCenter(
    center: Offset(x, y),
    width: radius * 2,
    height: radius * 2,
  );
}
