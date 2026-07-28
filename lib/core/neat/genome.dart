import 'activator.dart';
import 'neuron.dart';
import 'connection.dart';

class Genome {
  final int id;
  final List<Neuron> neurons;
  final List<Connection> connections;
  double fitness;
  double adjustedFitness;

  Genome({
    required this.id,
    required this.neurons,
    required this.connections,
    this.fitness = 0,
    this.adjustedFitness = 0,
  });

  List<double> forward(List<double> inputs) {
    for (final n in neurons) {
      n.value = 0;
      n.summed = 0;
    }

    int inputIdx = 0;
    for (final n in neurons) {
      if (n.type == NeuronType.input && inputIdx < inputs.length) {
        n.value = inputs[inputIdx++];
      } else if (n.type == NeuronType.bias) {
        n.value = 1;
      }
    }

    final sorted = _topologicalSort();

    for (final n in sorted) {
      if (n.type == NeuronType.input || n.type == NeuronType.bias) continue;

      double sum = 0;
      for (final c in connections) {
        if (!c.enabled || c.to != n.id) continue;
        final fromNeuron =
            neurons.where((nn) => nn.id == c.from).firstOrNull;
        if (fromNeuron != null) {
          sum += fromNeuron.value * c.weight;
        }
      }
      n.summed = sum;
      n.value = Activator.tanh(sum);
    }

    return neurons
        .where((n) => n.type == NeuronType.output)
        .map((n) => n.value)
        .toList();
  }

  List<Neuron> _topologicalSort() {
    final sorted = <Neuron>[];
    final visited = <int>{};

    void visit(int id) {
      if (visited.contains(id)) return;
      visited.add(id);

      for (final c in connections) {
        if (c.to == id && c.enabled) {
          visit(c.from);
        }
      }

      final neuron = neurons.firstWhere((n) => n.id == id);
      sorted.add(neuron);
    }

    final nodeIds = neurons.map((n) => n.id).toList();
    nodeIds.sort();
    for (final id in nodeIds) {
      visit(id);
    }

    return sorted;
  }

  int maxNeuronId() =>
      neurons.map((n) => n.id).reduce((a, b) => a > b ? a : b);

  Genome copy() {
    return Genome(
      id: id,
      neurons: neurons.map((n) => n.copy()).toList(),
      connections: connections.map((c) => c.copy()).toList(),
      fitness: fitness,
      adjustedFitness: adjustedFitness,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'neurons': neurons.map((n) => n.toJson()).toList(),
        'connections': connections.map((c) => c.toJson()).toList(),
        'fitness': fitness,
      };
}
