class SimulationConfig {
  final int populationSize;
  final double mutationRate;
  final double crossoverRate;
  final int maxGenerations;

  const SimulationConfig({
    this.populationSize = 50,
    this.mutationRate = 0.8,
    this.crossoverRate = 0.75,
    this.maxGenerations = 500,
  });
}
