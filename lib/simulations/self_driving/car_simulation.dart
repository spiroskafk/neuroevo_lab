import 'dart:ui';
import '../../core/neat/population.dart';
import '../base/simulation.dart';
import '../base/simulation_config.dart';
import 'car.dart';
import 'track.dart';
import 'car_painter.dart';

class CarSimulation extends SimulationBase {
  Track? _track;
  final List<Car> cars = [];
  Population? _population;
  bool _needsSpawn = false;

  static NEATConfig get defaultConfig => NEATConfig(
    numInputs: 7,
    numOutputs: 2,
    populationSize: 100,
    maxStagnation: 25,
    compatibilityThreshold: 1.5,
  );

  CarSimulation()
      : super(
          config: const SimulationConfig(),
          neatConfig: defaultConfig,
        );

  @override
  void init() {
    state.reset();
    _track = null;
    cars.clear();
    _population = Population.initial(neatConfig, seed: 42);
    state.speciesCount = _population!.species.length;
    _needsSpawn = true;
  }

  void _initTrack(Size size) {
    _track = Track.create(size, trackWidth: 40);
  }

  void _spawnCars() {
    final track = _track;
    if (track == null) {
      _needsSpawn = true;
      return;
    }
    cars.clear();
    final pop = _population!;
    for (int i = 0; i < pop.genomes.length; i++) {
      final car = Car(
        id: i,
        x: track.startPoint.dx,
        y: track.startPoint.dy,
        angle: track.startAngle,
      );
      cars.add(car);
    }
    _needsSpawn = false;
  }

  void _nextGeneration() {
    final pop = _population!;

    for (int i = 0; i < cars.length && i < pop.genomes.length; i++) {
      pop.genomes[i].fitness = cars[i].computeFitness();
    }

    pop.evolve();
    state.generation = pop.generation;
    if (pop.bestFitness > state.bestFitness) {
      state.bestFitness = pop.bestFitness;
    }
    state.averageFitness = pop.averageFitness;
    state.speciesCount = pop.species.length;
    state.speciesCountHistory.add(pop.species.length);
    final best = pop.bestGenome;
    state.neuronCountHistory.add(best.neurons.length);
    state.connectionCountHistory.add(best.connections.length);
    state.currentSpeciesDetails = pop.species.map((s) => {
      'id': s.id,
      'count': s.genomes.length,
      'fitness': s.bestFitness,
    }).toList();
    state.recordGeneration();
    _spawnCars();
  }

  @override
  void update(double dt) {
    if (_track == null) return;
    if (!state.isRunning) return;
    if (_population == null) return;
    final track = _track!;

    if (_needsSpawn) {
      _spawnCars();
    }

    if (cars.isEmpty || cars.every((c) => !c.alive)) {
      _nextGeneration();
      return;
    }

    final pop = _population!;
    state.aliveCount = cars.where((c) => c.alive).length;

    for (int i = 0; i < cars.length; i++) {
      final car = cars[i];
      if (!car.alive) continue;

      if (i < pop.genomes.length) {
        final genome = pop.genomes[i];
        final inputs = _getInputs(car);
        final outputs = genome.forward(inputs);

        final acceleration = outputs[0].clamp(-1, 1).toDouble();
        final steering = outputs[1].clamp(-1, 1).toDouble();

        car.update(dt, acceleration, steering);
        car.updateCheckpoint(track.centerPoints);
        car.updateStagnation(dt);

        if (!track.isOnTrack(car.x, car.y)) {
          car.kill();
        }
      }
    }

    double maxFitness = 0;
    int maxLaps = 0;
    int maxCheckpoint = 0;
    for (int i = 0; i < cars.length && i < pop.genomes.length; i++) {
      final c = cars[i];
      final f = c.computeFitness();
      if (f > maxFitness) {
        maxFitness = f;
        maxLaps = c.totalLaps;
        maxCheckpoint = c.checkpointIndex;
      }
    }
    if (maxFitness > state.bestFitness) {
      state.bestFitness = maxFitness;
      state.bestLaps = maxLaps;
      state.bestCheckpoint = maxCheckpoint;
    }
    state.metricLabel = 'Laps';
    state.metricValue = state.bestLaps;
  }

  List<double> _getInputs(Car car) {
    final track = _track!;
    final sensors = car.getSensorDistances(track.segments);
    final normalizedSensors = sensors.map((s) => (s / 300.0).clamp(0, 1).toDouble()).toList();
    final speed = (car.speed / Car.maxSpeed).clamp(-1, 1).toDouble();
    return [
      ...normalizedSensors,
      speed,
    ];
  }

  @override
  void render(Canvas canvas, Size size) {
    if (_track == null) _initTrack(size);
    final track = _track!;

    CarPainter.drawTrack(canvas, track);

    if (_population == null) return;
    final bestGenome = _population!.bestGenome;

    for (int i = 0; i < cars.length; i++) {
      final car = cars[i];
      final isBest = i < _population!.genomes.length &&
          _population!.genomes[i].id == bestGenome.id;

      CarPainter.drawSensors(canvas, car, track.segments);
      CarPainter.drawCar(canvas, car, isBest: isBest);
    }
  }

  @override
  void dispose() {
    _population = null;
    cars.clear();
    _track = null;
  }

  @override
  void reset() {
    init();
  }

  @override
  void toggleRunning() => state.toggleRunning();

  @override
  void setSpeed(double speed) => state.setSpeed(speed);

  @override
  Population? get population => _population;
}
