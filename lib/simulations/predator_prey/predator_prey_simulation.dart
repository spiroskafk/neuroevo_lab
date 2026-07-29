import 'dart:math';
import 'dart:ui';
import '../../core/neat/population.dart';
import '../base/simulation.dart';
import '../base/simulation_config.dart';
import 'creature.dart';
import 'world.dart';
import 'predator_prey_painter.dart';

class PredatorPreySimulation extends SimulationBase {
  World? _world;
  Population? _predatorPopulation;
  Population? _preyPopulation;
  double _arenaW = 600;
  double _arenaH = 400;
  int _genCounter = 0;
  double _genTime = 0;

  static const double maxGenTime = 60;

  static NEATConfig get predatorConfig => NEATConfig(
    numInputs: 6,
    numOutputs: 2,
    populationSize: 25,
    maxStagnation: 20,
    compatibilityThreshold: 1.5,
    mutateWeightsPower: 0.8,
    mutateAddNodeRate: 0.05,
    mutateAddConnectionRate: 0.1,
    crossoverRate: 0.7,
    survivalThreshold: 0.4,
  );

  static NEATConfig get preyConfig => NEATConfig(
    numInputs: 6,
    numOutputs: 2,
    populationSize: 30,
    maxStagnation: 20,
    compatibilityThreshold: 1.5,
    mutateWeightsPower: 0.6,
    mutateAddNodeRate: 0.03,
    mutateAddConnectionRate: 0.08,
    crossoverRate: 0.7,
    survivalThreshold: 0.4,
  );

  PredatorPreySimulation()
      : super(
          config: const SimulationConfig(),
          neatConfig: predatorConfig,
        );

  @override
  void init() {
    state.reset();
    _world = null;
    _predatorPopulation = Population.initial(predatorConfig, seed: 42);
    _preyPopulation = Population.initial(preyConfig, seed: 43);
    _genCounter = 0;
    _genTime = 0;
    _spawnWorld();
  }

  void _spawnWorld() {
    final rng = Random();
    final predators = <Creature>[];
    final prey = <Creature>[];

    final predPop = _predatorPopulation!;
    for (int i = 0; i < predPop.genomes.length; i++) {
      predators.add(Creature(
        id: i,
        type: CreatureType.predator,
        x: _arenaW / 2 + (rng.nextDouble() - 0.5) * 100,
        y: _arenaH / 2 + (rng.nextDouble() - 0.5) * 100,
      ));
    }

    final preyPop = _preyPopulation!;
    for (int i = 0; i < preyPop.genomes.length; i++) {
      prey.add(Creature(
        id: i,
        type: CreatureType.prey,
        x: World.margin + rng.nextDouble() * (_arenaW - World.margin * 2),
        y: World.margin + rng.nextDouble() * (_arenaH - World.margin * 2),
      ));
    }

    _world = World(
      width: _arenaW,
      height: _arenaH,
      predators: predators,
      prey: prey,
    );
  }

  static double _dist(double x1, double y1, double x2, double y2) {
    final dx = x1 - x2;
    final dy = y1 - y2;
    return sqrt(dx * dx + dy * dy);
  }

  List<double> _predatorInputs(Creature predator, World world) {
    final maxDist = _dist(0, 0, _arenaW, _arenaH);
    final nearest = world.nearestPrey(predator);

    double dirX = 0, dirY = 0, dist = 1;
    if (nearest != null) {
      final dx = nearest.x - predator.x;
      final dy = nearest.y - predator.y;
      dist = _dist(0, 0, dx, dy) / maxDist;
      final d = sqrt(dx * dx + dy * dy);
      if (d > 1) {
        dirX = dx / d;
        dirY = dy / d;
      }
    }

    final m = World.margin;
    final wallX = min(predator.x - m, _arenaW - m - predator.x) / _arenaW;
    final wallY = min(predator.y - m, _arenaH - m - predator.y) / _arenaH;

    return [
      dirX.clamp(-1, 1),
      dirY.clamp(-1, 1),
      dist.clamp(0, 1),
      wallX.clamp(0, 1),
      wallY.clamp(0, 1),
      (predator.energy / Creature.maxEnergy).clamp(0, 1),
    ];
  }

  List<double> _preyInputs(Creature prey_, World world) {
    final maxDist = _dist(0, 0, _arenaW, _arenaH);
    final nearestPred = world.nearestPredator(prey_);
    final nearestFood = world.nearestFood(prey_);

    double predDirX = 0, predDirY = 0, predDist = 1;
    if (nearestPred != null) {
      final dx = nearestPred.x - prey_.x;
      final dy = nearestPred.y - prey_.y;
      predDist = _dist(0, 0, dx, dy) / maxDist;
      final d = sqrt(dx * dx + dy * dy);
      if (d > 1) {
        predDirX = dx / d;
        predDirY = dy / d;
      }
    }

    double foodDist = 1;
    if (nearestFood != null) {
      final dx = nearestFood.x - prey_.x;
      final dy = nearestFood.y - prey_.y;
      foodDist = _dist(0, 0, dx, dy) / maxDist;
    }

    final m = World.margin;
    final wallX = min(prey_.x - m, _arenaW - m - prey_.x) / _arenaW;

    return [
      predDirX.clamp(-1, 1),
      predDirY.clamp(-1, 1),
      predDist.clamp(0, 1),
      foodDist.clamp(0, 1),
      wallX.clamp(0, 1),
      (prey_.energy / Creature.maxEnergy).clamp(0, 1),
    ];
  }

  void _nextGeneration() {
    final predPop = _predatorPopulation!;
    final preyPop = _preyPopulation!;
    final world = _world!;

    for (int i = 0; i < world.predators.length && i < predPop.genomes.length; i++) {
      final c = world.predators[i];
      predPop.genomes[i].fitness = c.score * 100 + c.age;
    }

    for (int i = 0; i < world.prey.length && i < preyPop.genomes.length; i++) {
      final c = world.prey[i];
      preyPop.genomes[i].fitness = c.age * 2 + c.score * 5;
    }

    predPop.evolve();
    preyPop.evolve();

    _genCounter++;
    state.generation = _genCounter;

    if (predPop.bestFitness > state.bestFitness) {
      state.bestFitness = predPop.bestFitness;
    }
    state.averageFitness = predPop.averageFitness;
    state.speciesCount = predPop.species.length + preyPop.species.length;

    state.speciesCountHistory.add(state.speciesCount);
    state.neuronCountHistory.add(predPop.bestGenome.neurons.length);
    state.connectionCountHistory.add(predPop.bestGenome.connections.length);

    state.currentSpeciesDetails = [
      ...predPop.species.map((s) => {
        'id': s.id,
        'count': s.genomes.length,
        'fitness': s.bestFitness,
      }),
      ...preyPop.species.map((s) => {
        'id': s.id,
        'count': s.genomes.length,
        'fitness': s.bestFitness,
      }),
    ];

    state.recordGeneration();
    _genTime = 0;
    _spawnWorld();
  }

  @override
  void update(double dt) {
    if (!state.isRunning) return;
    final world = _world;
    if (world == null) return;

    _genTime += dt;
    final allPreyDead = world.prey.every((c) => !c.alive);
    final allPredDead = world.predators.every((c) => !c.alive);

    if ((allPreyDead || allPredDead) && _genTime > 1) {
      _nextGeneration();
      return;
    }
    if (_genTime > maxGenTime) {
      _nextGeneration();
      return;
    }

    final predPop = _predatorPopulation!;
    final preyPop = _preyPopulation!;

    for (int i = 0; i < world.predators.length; i++) {
      final c = world.predators[i];
      if (!c.alive) continue;
      if (i < predPop.genomes.length) {
        final outputs = predPop.genomes[i].forward(_predatorInputs(c, world));
        c.dx = outputs[0].clamp(-1, 1);
        c.dy = outputs[1].clamp(-1, 1);
        c.update(dt);
        world.clampToBounds(c);
      }
    }

    for (int i = 0; i < world.prey.length; i++) {
      final c = world.prey[i];
      if (!c.alive) continue;
      if (i < preyPop.genomes.length) {
        final outputs = preyPop.genomes[i].forward(_preyInputs(c, world));
        c.dx = outputs[0].clamp(-1, 1);
        c.dy = outputs[1].clamp(-1, 1);
        c.update(dt);
        world.clampToBounds(c);
      }
    }

    world.checkPredatorPreyCollisions();
    world.checkPreyFoodCollisions();
    world.refillFood();

    final alivePred = world.predators.where((c) => c.alive).length;
    final alivePrey = world.prey.where((c) => c.alive).length;
    state.aliveCount = alivePred + alivePrey;

    double bestScore = 0;
    for (final c in world.predators) {
      final f = c.score * 100.0 + c.age;
      if (f > bestScore) bestScore = f;
    }
    if (bestScore > state.bestFitness) {
      state.bestFitness = bestScore;
    }
    state.metricLabel = 'Score';
    state.metricValue = bestScore.toInt();
  }

  @override
  void render(Canvas canvas, Size size) {
    _arenaW = size.width;
    _arenaH = size.height;

    PredatorPreyPainter.drawBackground(canvas, size);
    final world = _world;
    if (world == null) return;

    PredatorPreyPainter.drawFoods(canvas, world.foods);

    for (final c in world.predators) {
      PredatorPreyPainter.drawCreature(canvas, c);
    }
    for (final c in world.prey) {
      PredatorPreyPainter.drawCreature(canvas, c);
    }
  }

  @override
  void dispose() {
    _predatorPopulation = null;
    _preyPopulation = null;
    _world = null;
  }

  @override
  void reset() => init();

  @override
  void toggleRunning() => state.toggleRunning();

  @override
  void setSpeed(double speed) => state.setSpeed(speed);

  @override
  Population? get population => _predatorPopulation;
}
