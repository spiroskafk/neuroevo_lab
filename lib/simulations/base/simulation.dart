import 'dart:ui';
import '../../../core/neat/population.dart';
import 'evolution_state.dart';
import 'simulation_config.dart';

abstract class SimulationBase {
  final EvolutionState state = EvolutionState();
  final SimulationConfig config;
  final NEATConfig neatConfig;

  SimulationBase({
    required this.config,
    required this.neatConfig,
  });

  void init();
  void update(double dt);
  void render(Canvas canvas, Size size);
  void dispose();

  void reset();
  void toggleRunning();
  void setSpeed(double speed);

  Population? get population => null;
}
