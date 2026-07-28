import 'dart:ui';
import '../../core/neat/population.dart';
import '../base/simulation.dart';
import '../base/simulation_config.dart';
import 'car.dart';
import 'track.dart';
import 'car_painter.dart';

class CarSimulation extends SimulationBase {
  late Track track;
  final List<Car> cars = [];
  Population? _population;

  CarSimulation()
      : super(
          config: const SimulationConfig(),
          neatConfig: NEATConfig(
            numInputs: 7,
            numOutputs: 2,
            populationSize: 50,
          ),
        );

  @override
  void init() {
    state.reset();
    cars.clear();
    _population = Population.initial(neatConfig, seed: 42);
  }

  void _initTrack(Size size) {
    track = Track.create(size, trackWidth: 40);
  }

  void _spawnCars() {
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
  }

  @override
  void update(double dt) {
    if (!state.isRunning) return;
    if (_population == null) return;

    if (cars.isEmpty || cars.every((c) => !c.alive)) {
      _population!.evolve();
      state.generation = _population!.generation;
      state.bestFitness = _population!.bestFitness;
      state.averageFitness = _population!.averageFitness;
      state.recordGeneration();
      _spawnCars();
      return;
    }

    final pop = _population!;
    state.aliveCount = cars.where((c) => c.alive).length;
    final bestGenome = pop.bestGenome;

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

        if (!track.isOnTrack(car.x, car.y)) {
          car.kill();
        }

        genome.fitness = car.distanceTraveled;
      }
    }

    if (bestGenome.fitness > state.bestFitness) {
      state.bestFitness = bestGenome.fitness;
    }
  }

  List<double> _getInputs(Car car) {
    final sensors = car.getSensorDistances(track.segments);
    final normalizedSensors = sensors.map((s) => s / 300.0).toList();
    final speed = (car.speed / Car.maxSpeed).clamp(-1, 1).toDouble();
    return [
      ...normalizedSensors,
      speed,
    ];
  }

  @override
  void render(Canvas canvas, Size size) {
    if (track.bounds.isEmpty) _initTrack(size);

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
  }

  @override
  void reset() {
    init();
    state.reset();
  }

  @override
  void toggleRunning() => state.toggleRunning();

  @override
  void setSpeed(double speed) => state.setSpeed(speed);

  @override
  Population? get population => _population;
}
