import 'dart:math';

abstract class Activator {
  static double sigmoid(double x) => 1 / (1 + exp(-x));
  static double tanh(double x) => 2 / (1 + exp(-2 * x)) - 1;
  static double relu(double x) => x > 0 ? x : 0;
  static double leakyRelu(double x) => x > 0 ? x : 0.01 * x;
  static double gaussian(double x) => exp(-x * x);
  static double step(double x) => x > 0 ? 1 : 0;
  static double identity(double x) => x;
}
