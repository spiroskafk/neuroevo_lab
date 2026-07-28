import 'dart:math';
import 'genome.dart';

class Species {
  final int id;
  final List<Genome> genomes;
  Genome? representative;
  int stagnationCounter;
  double bestFitness;
  double averageFitness;

  Species({
    required this.id,
    required this.representative,
    List<Genome>? genomes,
    this.stagnationCounter = 0,
    this.bestFitness = double.negativeInfinity,
    this.averageFitness = 0,
  }) : genomes = genomes ?? [];

  static double compatibilityDistance(Genome g1, Genome g2,
      {double c1 = 1, double c2 = 1, double c3 = 0.4}) {
    int excess = 0;
    int disjoint = 0;
    double weightDiff = 0;
    int matching = 0;

    final g1Innovations = g1.connections.map((c) => c.innovation).toSet();
    final g2Innovations = g2.connections.map((c) => c.innovation).toSet();
    final allInnovations = g1Innovations.union(g2Innovations);
    final maxG1 = g1Innovations.isEmpty ? 0 : g1Innovations.reduce((a, b) => a > b ? a : b);
    final maxG2 = g2Innovations.isEmpty ? 0 : g2Innovations.reduce((a, b) => a > b ? a : b);
    final n = max(allInnovations.length, 1);

    for (final innov in allInnovations) {
      final inG1 = g1Innovations.contains(innov);
      final inG2 = g2Innovations.contains(innov);

      if (inG1 && inG2) {
        final c1Gene = g1.connections.firstWhere((c) => c.innovation == innov);
        final c2Gene = g2.connections.firstWhere((c) => c.innovation == innov);
        weightDiff += (c1Gene.weight - c2Gene.weight).abs();
        matching++;
      } else {
        if (innov > maxG1 || innov > maxG2) {
          excess++;
        } else {
          disjoint++;
        }
      }
    }

    final avgWeightDiff = matching > 0 ? weightDiff / matching : 0;
    return (c1 * excess) / n + (c2 * disjoint) / n + c3 * avgWeightDiff;
  }

  void addGenome(Genome g) {
    genomes.add(g);
  }

  bool isStagnant(int maxStagnation) {
    return stagnationCounter >= maxStagnation;
  }
}
