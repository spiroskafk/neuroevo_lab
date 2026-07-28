import 'package:flutter/foundation.dart';

class EvolutionState extends ChangeNotifier {
  int generation = 0;
  int aliveCount = 0;
  int speciesCount = 0;
  int bestLaps = 0;
  int bestCheckpoint = 0;
  String metricLabel = 'Laps';
  int metricValue = 0;
  double bestFitness = 0;
  double averageFitness = 0;
  double genTimeMs = 0;
  bool isRunning = false;
  double speedMultiplier = 1;
  bool showNetwork = false;

  final List<double> bestFitnessHistory = [];
  final List<double> averageFitnessHistory = [];
  final List<int> speciesCountHistory = [];
  final List<int> neuronCountHistory = [];
  final List<int> connectionCountHistory = [];
  List<Map<String, dynamic>> currentSpeciesDetails = const [];

  void reset() {
    generation = 0;
    aliveCount = 0;
    speciesCount = 0;
    bestLaps = 0;
    bestCheckpoint = 0;
    metricLabel = 'Laps';
    metricValue = 0;
    bestFitness = 0;
    averageFitness = 0;
    genTimeMs = 0;
    bestFitnessHistory.clear();
    averageFitnessHistory.clear();
    speciesCountHistory.clear();
    neuronCountHistory.clear();
    connectionCountHistory.clear();
    currentSpeciesDetails = const [];
    notifyListeners();
  }

  void recordGeneration() {
    bestFitnessHistory.add(bestFitness);
    averageFitnessHistory.add(averageFitness);
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

  void toggleNetwork() {
    showNetwork = !showNetwork;
    notifyListeners();
  }
}
