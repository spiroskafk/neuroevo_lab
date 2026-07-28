import 'dart:math';
import 'dart:ui';

class Car {
  double x;
  double y;
  double angle;
  double speed;
  double width;
  double height;
  bool alive;
  double distanceTraveled;
  int id;

  Car({
    required this.id,
    required this.x,
    required this.y,
    this.angle = 0,
    this.speed = 0,
    this.width = 20,
    this.height = 12,
    this.alive = true,
    this.distanceTraveled = 0,
  });

  static const double maxSpeed = 200;
  static const double accelerationForce = 150;
  static const double brakeForce = 100;
  static const double friction = 0.95;
  static const double turnSpeed = 3;

  void update(double dt, double acceleration, double steering) {
    if (!alive) return;

    speed += acceleration * accelerationForce * dt;
    speed -= speed * (1 - friction) * dt;
    speed = speed.clamp(-maxSpeed * 0.3, maxSpeed);

    angle += steering * turnSpeed * dt;

    if (speed.abs() > 1) {
      x += cos(angle) * speed * dt;
      y += sin(angle) * speed * dt;
      distanceTraveled += speed.abs() * dt;
    }
  }

  void kill() {
    alive = false;
    speed = 0;
  }

  void reset(double startX, double startY, double startAngle) {
    x = startX;
    y = startY;
    angle = startAngle;
    speed = 0;
    alive = true;
    distanceTraveled = 0;
  }

  List<double> getSensorDistances(List<List<Offset>> trackSegments) {
    const sensorAngles = [-pi / 2, -pi / 4, 0, pi / 4, pi / 2];
    final distances = <double>[];

    for (final sensorAngle in sensorAngles) {
      final rayAngle = angle + sensorAngle;
      double minDist = double.infinity;

      for (final segment in trackSegments) {
        final intersection = _rayIntersectSegment(
          x, y, rayAngle, segment[0].dx, segment[0].dy, segment[1].dx, segment[1].dy,
        );
        if (intersection != null && intersection > 0) {
          if (intersection < minDist) minDist = intersection;
        }
      }

      distances.add(minDist == double.infinity ? 300 : minDist.clamp(0, 300));
    }

    return distances;
  }

  double? _rayIntersectSegment(
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
