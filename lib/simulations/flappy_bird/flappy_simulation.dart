import 'dart:math';
import 'dart:ui';
import '../../core/neat/population.dart';
import '../base/simulation.dart';
import '../base/simulation_config.dart';
import 'bird.dart';
import 'pipe.dart';
import 'flappy_painter.dart';

class FlappyBirdSimulation extends SimulationBase {
  final List<Bird> birds = [];
  final List<Pipe> pipes = [];
  Population? _population;
  Random _rng = Random();
  double _nextPipeX = 400;
  double _screenHeight = 800;
  int _maxFitness = 0;

  FlappyBirdSimulation()
      : super(
          config: const SimulationConfig(),
          neatConfig: NEATConfig(
          numInputs: 4,
          numOutputs: 1,
            populationSize: 100,
            maxStagnation: 25,
            compatibilityThreshold: 1.5,
          ),
        );

  @override
  void init() {
    state.reset();
    birds.clear();
    pipes.clear();
    _maxFitness = 0;
    _population = Population.initial(neatConfig, seed: 42);
    _rng = Random(42);
    _nextPipeX = 400;
    _spawnBirds();
  }

  void _spawnBirds() {
    birds.clear();
    final pop = _population!;
    for (int i = 0; i < pop.genomes.length; i++) {
      birds.add(Bird(id: i, screenHeight: _screenHeight));
    }
  }

  Pipe _createPipe(double x) {
    return Pipe(x: x, screenHeight: _screenHeight, rng: _rng);
  }

  void _nextGeneration() {
    final pop = _population!;

    for (int i = 0; i < birds.length && i < pop.genomes.length; i++) {
      pop.genomes[i].fitness = birds[i].fitness.toDouble();
    }

    pop.evolve();
    state.generation = pop.generation;
    if (pop.bestFitness > state.bestFitness) {
      state.bestFitness = pop.bestFitness;
    }
    if (pop.bestFitness > _maxFitness) {
      _maxFitness = pop.bestFitness.toInt();
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
    _spawnBirds();
    pipes.clear();
    _nextPipeX = 400;
  }

  @override
  void update(double dt) {
    if (!state.isRunning || _population == null) return;

    if (birds.isEmpty || birds.every((b) => !b.alive)) {
      _nextGeneration();
      return;
    }

    state.aliveCount = birds.where((b) => b.alive).length;

    final pop = _population!;

    for (int i = 0; i < birds.length; i++) {
      final bird = birds[i];
      if (!bird.alive) continue;

      if (i < pop.genomes.length) {
        final genome = pop.genomes[i];
        final inputs = _getInputs(bird);
        final outputs = genome.forward(inputs);

        if (outputs[0] > 0.5) {
          bird.flap();
        }

        bird.update(dt, _screenHeight);
      }
    }

    for (final pipe in pipes) {
      pipe.update(dt);
    }
    pipes.removeWhere((p) => p.isOffScreen);

    _nextPipeX -= Pipe.speed * dt;
    if (_nextPipeX <= 200) {
      pipes.add(_createPipe(state.generation == 0 ? 400 : 600));
      _nextPipeX = 400;
    }

    for (final bird in birds) {
      if (!bird.alive) continue;

      bird.fitness++;

      final nextPipe = pipes.where((p) => p.x + p.width > bird.x).firstOrNull;

      if (nextPipe != null) {
        final dist = (nextPipe.x - bird.x).abs();
        if (dist < 300) {
          final verticalDist = (nextPipe.gapCenter - bird.y).abs();
          final alignment = (1 - verticalDist / (nextPipe.gapSize / 2)).clamp(0.0, 1.0);
          bird.fitness += (alignment * 60).round();
        }
      }

      for (final pipe in pipes) {
        if (!pipe.scored && pipe.x + pipe.width < bird.x) {
          bird.fitness += 50;
          pipe.scored = true;
        }
        if (pipe.collides(bird.rect)) {
          bird.alive = false;
          break;
        }
      }
    }

    double maxFitness = 0;
    for (final b in birds) {
      if (b.fitness > maxFitness) maxFitness = b.fitness.toDouble();
    }
    if (maxFitness > state.bestFitness) {
      state.bestFitness = maxFitness;
    }
    state.metricLabel = 'Score';
    state.metricValue = state.bestFitness.toInt();
  }

  List<double> _getInputs(Bird bird) {
    final nextPipe = pipes.where((p) => p.x + p.width > bird.x).firstOrNull;
    final pipeX = nextPipe?.x ?? _nextPipeX;
    final gapCenter = nextPipe?.gapCenter ?? _screenHeight / 2;

    return [
      bird.y / _screenHeight,
      (gapCenter - bird.y) / (_screenHeight / 2),
      (pipeX - bird.x) / 600,
      bird.velocity / 500,
    ];
  }

  @override
  void render(Canvas canvas, Size size) {
    _screenHeight = size.height;
    FlappyPainter.drawBackground(canvas, size);
    FlappyPainter.drawPipes(canvas, pipes);

    for (final bird in birds) {
      FlappyPainter.drawBird(canvas, bird);
    }
  }

  @override
  void dispose() {
    _population = null;
    birds.clear();
    pipes.clear();
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
