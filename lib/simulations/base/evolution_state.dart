import 'package:flutter/foundation.dart';

class EvolutionState extends ChangeNotifier {
  int generation = 0;
  int aliveCount = 0;
  double bestFitness = 0;
  double averageFitness = 0;
  bool isRunning = false;
  double speedMultiplier = 1;
  bool showNetwork = false;

  final List<double> bestFitnessHistory = [];
  final List<double> averageFitnessHistory = [];
  final List<int> generationHistory = [];

  void reset() {
    generation = 0;
    aliveCount = 0;
    bestFitness = 0;
    averageFitness = 0;
    bestFitnessHistory.clear();
    averageFitnessHistory.clear();
    generationHistory.clear();
    notifyListeners();
  }

  void recordGeneration() {
    bestFitnessHistory.add(bestFitness);
    averageFitnessHistory.add(averageFitness);
    generationHistory.add(generation);
    notifyListeners();
  }

  void toggleRunning() {
    isRunning = !isRunning;
    notifyListeners();
  }

  void setSpeed(double speed) {
    speedMultiplier = speed;
    notifyListeners();
  }
}
