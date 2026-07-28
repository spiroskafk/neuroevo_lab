import 'dart:math';
import 'neuron.dart';
import 'connection.dart';
import 'genome.dart';
import 'species.dart';

class NEATConfig {
  final int populationSize;
  final double mutateWeightsRate;
  final double mutateWeightsPower;
  final double mutateAddNodeRate;
  final double mutateAddConnectionRate;
  final double mutateToggleRate;
  final double crossoverRate;
  final double survivalThreshold;
  final int maxStagnation;
  final double compatibilityThreshold;
  final int numInputs;
  final int numOutputs;

  NEATConfig({
    this.populationSize = 50,
    this.mutateWeightsRate = 0.8,
    this.mutateWeightsPower = 0.5,
    this.mutateAddNodeRate = 0.03,
    this.mutateAddConnectionRate = 0.05,
    this.mutateToggleRate = 0.01,
    this.crossoverRate = 0.75,
    this.survivalThreshold = 0.5,
    this.maxStagnation = 15,
    this.compatibilityThreshold = 3.0,
    this.numInputs = 5,
    this.numOutputs = 2,
  });
}

class Innovation {
  final int innovationId;
  final int from;
  final int to;

  Innovation({
    required this.innovationId,
    required this.from,
    required this.to,
  });
}

class Population {
  final NEATConfig config;
  final List<Genome> genomes;
  final List<Species> species;
  final Random _rng;
  final List<Innovation> _innovations;
  int _nextInnovation;
  int _nextGenome;
  int _nextSpecies;
  int generation;
  double bestFitness;
  double averageFitness;

  Population({
    required this.config,
    List<Genome>? genomes,
    List<Species>? species,
    int? seed,
  })  : genomes = genomes ?? [],
        species = species ?? [],
        _rng = Random(seed ?? DateTime.now().microsecondsSinceEpoch),
        _innovations = [],
        _nextInnovation = 0,
        _nextGenome = 0,
        _nextSpecies = 0,
        generation = 0,
        bestFitness = double.negativeInfinity,
        averageFitness = 0;

  factory Population.initial(NEATConfig config, {int? seed}) {
    final pop = Population(config: config, seed: seed);
    pop._initialize();
    return pop;
  }

  void _initialize() {
    for (int i = 0; i < config.populationSize; i++) {
      final genome = _createMinimalGenome();
      genomes.add(genome);
    }
    _speciate();
  }

  Genome _createMinimalGenome() {
    final id = _nextGenome++;
    final neurons = <Neuron>[];

    neurons.add(Neuron(id: 0, type: NeuronType.bias));
    for (int i = 0; i < config.numInputs; i++) {
      neurons.add(Neuron(id: i + 1, type: NeuronType.input));
    }
    final numNeurons = 1 + config.numInputs;
    for (int i = 0; i < config.numOutputs; i++) {
      neurons.add(Neuron(id: numNeurons + i, type: NeuronType.output));
    }

    final connections = <Connection>[];

    void addConnection(int from, int to) {
      final existing = _innovations.cast<Innovation?>().firstWhere(
        (inv) => inv!.from == from && inv.to == to,
        orElse: () => null,
      );
      final int innov;
      if (existing != null) {
        innov = existing.innovationId;
      } else {
        innov = _nextInnovation++;
        _innovations.add(Innovation(
          innovationId: innov,
          from: from,
          to: to,
        ));
      }
      connections.add(Connection(
        innovation: innov,
        from: from,
        to: to,
        weight: _rng.nextDouble() * 2 - 1,
      ));
    }

    for (int i = 0; i < config.numInputs; i++) {
      for (int j = 0; j < config.numOutputs; j++) {
        addConnection(i + 1, numNeurons + j);
      }
    }
    for (int j = 0; j < config.numOutputs; j++) {
      addConnection(0, numNeurons + j);
    }

    return Genome(id: id, neurons: neurons, connections: connections);
  }

  void evolve() {
    _calculateFitness();
    _speciate();
    _removeStagnantSpecies();
    _reproduce();
    generation++;
  }

  void _calculateFitness() {
    bestFitness = double.negativeInfinity;
    double totalFitness = 0;
    for (final g in genomes) {
      if (g.fitness > bestFitness) bestFitness = g.fitness;
      totalFitness += g.fitness;
    }
    averageFitness = genomes.isNotEmpty ? totalFitness / genomes.length : 0;

    for (final s in species) {
      if (s.genomes.isEmpty) continue;
      final best = s.genomes
          .reduce((a, b) => a.fitness > b.fitness ? a : b);
      if (best.fitness > s.bestFitness) {
        s.bestFitness = best.fitness;
        s.stagnationCounter = 0;
      } else {
        s.stagnationCounter++;
      }
      final speciesSum = s.genomes.fold(
        0.0,
        (prev, g) => prev + g.fitness,
      );
      s.averageFitness =
          s.genomes.isNotEmpty ? speciesSum / s.genomes.length : 0;

      for (final g in s.genomes) {
        g.adjustedFitness = g.fitness / s.genomes.length;
      }
    }
  }

  void _speciate() {
    for (final s in species) {
      s.genomes.clear();
    }

    for (final g in genomes) {
      bool placed = false;
      for (final s in species) {
        if (s.representative == null) continue;
        final dist = Species.compatibilityDistance(g, s.representative!);
        if (dist < config.compatibilityThreshold) {
          s.addGenome(g);
          placed = true;
          break;
        }
      }
      if (!placed) {
        final newSpecies = Species(
          id: _nextSpecies++,
          representative: g,
        );
        newSpecies.addGenome(g);
        species.add(newSpecies);
      }
    }

    species.removeWhere((s) => s.genomes.isEmpty);

    for (final s in species) {
      s.representative = s.genomes[_rng.nextInt(s.genomes.length)].copy();
    }
  }

  void _removeStagnantSpecies() {
    final nonEmpty = species.where((s) => s.genomes.isNotEmpty).toList();
    if (nonEmpty.length <= 1) return;

    final maxFitness =
        nonEmpty.map((s) => s.bestFitness).reduce((a, b) => a > b ? a : b);

    species.removeWhere((s) {
      if (s.genomes.isEmpty) return true;
      if (s.isStagnant(config.maxStagnation) && s.bestFitness < maxFitness) {
        return true;
      }
      return false;
    });
  }

  void _reproduce() {
    final newGenomes = <Genome>[];

    final totalAdjusted =
        genomes.fold(0.0, (prev, g) => prev + g.adjustedFitness);
    if (totalAdjusted <= 0) {
      for (int i = 0; i < config.populationSize; i++) {
        newGenomes.add(_createMinimalGenome());
      }
      genomes.clear();
      genomes.addAll(newGenomes);
      return;
    }

    final bestEver = genomes.reduce((a, b) => a.fitness > b.fitness ? a : b);

    for (final s in species) {
      if (s.genomes.isEmpty) continue;

      final speciesSum =
          s.genomes.fold(0.0, (prev, g) => prev + g.adjustedFitness);
      final offspringCount =
          ((speciesSum / totalAdjusted) * config.populationSize).round();

      if (offspringCount <= 0) continue;

      final sorted = List<Genome>.from(s.genomes)
        ..sort((a, b) => b.fitness.compareTo(a.fitness));

      final keepCount =
          (sorted.length * config.survivalThreshold).ceil().clamp(1, sorted.length);
      final eligible = sorted.sublist(0, keepCount);

      newGenomes.add(sorted[0].copy());

      for (int i = 1; i < offspringCount; i++) {
        if (eligible.length == 1) {
          final child = eligible[0].copy();
          _mutate(child);
          newGenomes.add(child);
        } else {
          final parent1 = eligible[_rng.nextInt(eligible.length)];
          final parent2 = eligible[_rng.nextInt(eligible.length)];
          Genome child;
          if (_rng.nextDouble() < config.crossoverRate) {
            child = _crossover(parent1, parent2);
          } else {
            child = parent1.copy();
          }
          _mutate(child);
          newGenomes.add(child);
        }
      }
    }

    if (bestEver.fitness > 0) {
      newGenomes.add(bestEver.copy());
    }

    while (newGenomes.length < config.populationSize) {
      final child = _createMinimalGenome();
      _mutate(child);
      newGenomes.add(child);
    }

    if (newGenomes.length > config.populationSize) {
      newGenomes.sort((a, b) => b.fitness.compareTo(a.fitness));
      final excess = newGenomes.length - config.populationSize;
      newGenomes.removeRange(newGenomes.length - excess, newGenomes.length);
    }

    genomes.clear();
    genomes.addAll(newGenomes);
  }

  Genome _crossover(Genome parent1, Genome parent2) {
    final fitter = parent1.fitness >= parent2.fitness ? parent1 : parent2;
    final weaker = parent1.fitness >= parent2.fitness ? parent2 : parent1;

    final childConnections = <Connection>[];

    final p2Innovations =
        weaker.connections.map((c) => c.innovation).toSet();

    for (final c in fitter.connections) {
      if (p2Innovations.contains(c.innovation)) {
        final p2Gene =
            weaker.connections.firstWhere((gc) => gc.innovation == c.innovation);
        final useFirst = _rng.nextBool();
        childConnections.add(Connection(
          innovation: c.innovation,
          from: c.from,
          to: c.to,
          weight: useFirst ? c.weight : p2Gene.weight,
          enabled: c.enabled && p2Gene.enabled,
        ));
      } else {
        childConnections.add(c.copy());
      }
    }

    childConnections.sort((a, b) => a.innovation.compareTo(b.innovation));

    final childNeurons = <int, Neuron>{};
    for (final c in childConnections) {
      childNeurons.putIfAbsent(
        c.from,
        () => Neuron(
          id: c.from,
          type: _getNeuronType(c.from, parent1, parent2),
        ),
      );
      childNeurons.putIfAbsent(
        c.to,
        () => Neuron(
          id: c.to,
          type: _getNeuronType(c.to, parent1, parent2),
        ),
      );
    }

    return Genome(
      id: _nextGenome++,
      neurons: childNeurons.values.toList(),
      connections: childConnections,
    );
  }

  NeuronType _getNeuronType(int id, Genome g1, Genome g2) {
    for (final n in g1.neurons) {
      if (n.id == id) return n.type;
    }
    for (final n in g2.neurons) {
      if (n.id == id) return n.type;
    }
    return NeuronType.hidden;
  }

  void _mutate(Genome genome) {
    if (_rng.nextDouble() < config.mutateWeightsRate) {
      _mutateWeights(genome);
    }
    if (_rng.nextDouble() < config.mutateAddConnectionRate) {
      _mutateAddConnection(genome);
    }
    if (_rng.nextDouble() < config.mutateAddNodeRate) {
      _mutateAddNode(genome);
    }
    if (_rng.nextDouble() < config.mutateToggleRate) {
      _mutateToggle(genome);
    }
  }

  void _mutateWeights(Genome genome) {
    for (final c in genome.connections) {
      if (_rng.nextDouble() < 0.1) {
        c.weight = _rng.nextDouble() * 2 - 1;
      } else {
        c.weight += _gauss() * config.mutateWeightsPower;
        c.weight = c.weight.clamp(-3, 3);
      }
    }
  }

  void _mutateAddConnection(Genome genome) {
    final neurons = genome.neurons;
    final existing =
        genome.connections.map((c) => '${c.from}-${c.to}').toSet();

    for (int attempt = 0; attempt < 10; attempt++) {
      final from = neurons[_rng.nextInt(neurons.length)];
      final to = neurons[_rng.nextInt(neurons.length)];

      if (from.id == to.id) continue;
      if (existing.contains('${from.id}-${to.id}')) continue;
      if (_createsCycle(from.id, to.id, genome)) continue;
      if (from.type == NeuronType.output && to.type != NeuronType.hidden) continue;
      if (to.type == NeuronType.input) continue;

      int innov;
      final existingInnov = _innovations.where(
        (i) => i.from == from.id && i.to == to.id,
      );
      if (existingInnov.isNotEmpty) {
        innov = existingInnov.first.innovationId;
      } else {
        innov = _nextInnovation++;
        _innovations.add(Innovation(
          innovationId: innov,
          from: from.id,
          to: to.id,
        ));
      }

      genome.connections.add(Connection(
        innovation: innov,
        from: from.id,
        to: to.id,
        weight: _rng.nextDouble() * 2 - 1,
      ));
      return;
    }
  }

  double _gauss() {
    final u1 = _rng.nextDouble();
    final u2 = _rng.nextDouble();
    return sqrt(-2 * log(u1 + 1e-10)) * cos(2 * pi * u2);
  }

  bool _createsCycle(int from, int to, Genome genome) {
    if (from == to) return true;
    final visited = <int>{};

    bool dfs(int current) {
      if (current == from) return true;
      if (visited.contains(current)) return false;
      visited.add(current);
      for (final c in genome.connections) {
        if (c.from == current && c.enabled) {
          if (dfs(c.to)) return true;
        }
      }
      return false;
    }

    return dfs(to);
  }

  void _mutateAddNode(Genome genome) {
    final enabled = genome.connections.where((c) => c.enabled).toList();
    if (enabled.isEmpty) return;

    final toSplit = enabled[_rng.nextInt(enabled.length)];
    toSplit.enabled = false;

    final newNodeId = genome.maxNeuronId() + 1;
    genome.neurons.add(Neuron(
      id: newNodeId,
      type: NeuronType.hidden,
    ));

    Connection? conn1;
    Connection? conn2;

    final innov1 = _innovations.where(
      (i) => i.from == toSplit.from && i.to == newNodeId,
    );
    if (innov1.isNotEmpty) {
      conn1 = Connection(
        innovation: innov1.first.innovationId,
        from: toSplit.from,
        to: newNodeId,
        weight: 1,
      );
    } else {
      final innov = _nextInnovation++;
      _innovations.add(Innovation(
        innovationId: innov,
        from: toSplit.from,
        to: newNodeId,
      ));
      conn1 = Connection(innovation: innov, from: toSplit.from, to: newNodeId, weight: 1);
    }

    final innov2 = _innovations.where(
      (i) => i.from == newNodeId && i.to == toSplit.to,
    );
    if (innov2.isNotEmpty) {
      conn2 = Connection(
        innovation: innov2.first.innovationId,
        from: newNodeId,
        to: toSplit.to,
        weight: toSplit.weight,
      );
    } else {
      final innov = _nextInnovation++;
      _innovations.add(Innovation(
        innovationId: innov,
        from: newNodeId,
        to: toSplit.to,
      ));
      conn2 = Connection(
        innovation: innov,
        from: newNodeId,
        to: toSplit.to,
        weight: toSplit.weight,
      );
    }

    genome.connections.add(conn1);
    genome.connections.add(conn2);
  }

  void _mutateToggle(Genome genome) {
    if (genome.connections.isEmpty) return;
    final c = genome.connections[_rng.nextInt(genome.connections.length)];
    c.enabled = !c.enabled;
  }

  Genome get bestGenome {
    return genomes.reduce((a, b) => a.fitness > b.fitness ? a : b);
  }
}
