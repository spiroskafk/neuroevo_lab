enum NeuronType { input, hidden, output, bias }

class Neuron {
  final int id;
  final NeuronType type;
  double value;
  double summed;

  Neuron({
    required this.id,
    required this.type,
    this.value = 0,
    this.summed = 0,
  });

  Neuron copy() => Neuron(id: id, type: type, value: value, summed: summed);

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
      };
}
