import 'package:flutter/material.dart';
import '../simulations/base/evolution_state.dart';

class InfoOverlay extends StatelessWidget {
  final EvolutionState state;

  const InfoOverlay({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xAA0F0F23),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _infoChip('Gen', '${state.generation}'),
          const SizedBox(width: 12),
          _infoChip('Alive', '${state.aliveCount}'),
          const SizedBox(width: 12),
          _infoChip('Best', state.bestFitness.toStringAsFixed(0)),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
