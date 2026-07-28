class Connection {
  final int innovation;
  final int from;
  final int to;
  double weight;
  bool enabled;

  Connection({
    required this.innovation,
    required this.from,
    required this.to,
    required this.weight,
    this.enabled = true,
  });

  Connection copy() => Connection(
        innovation: innovation,
        from: from,
        to: to,
        weight: weight,
        enabled: enabled,
      );

  Map<String, dynamic> toJson() => {
        'innovation': innovation,
        'from': from,
        'to': to,
        'weight': weight,
        'enabled': enabled,
      };
}
