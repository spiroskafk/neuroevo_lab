import 'dart:math';

class MathUtils {
  static double distance(double x1, double y1, double x2, double y2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));
  }

  static double angleBetween(double x1, double y1, double x2, double y2) {
    return atan2(y2 - y1, x2 - x1);
  }

  static double normalizeAngle(double angle) {
    while (angle > pi) { angle -= 2 * pi; }
    while (angle < -pi) { angle += 2 * pi; }
    return angle;
  }

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static double clamp(double value, double min, double max) =>
      value < min ? min : (value > max ? max : value);
}
