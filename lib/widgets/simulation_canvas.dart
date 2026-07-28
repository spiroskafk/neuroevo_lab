import 'package:flutter/material.dart';
import '../simulations/base/simulation.dart';

class SimulationCanvas extends StatelessWidget {
  final SimulationBase simulation;

  const SimulationCanvas({super.key, required this.simulation});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F23),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(
            painter: _SimulationPainter(simulation),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

class _SimulationPainter extends CustomPainter {
  final SimulationBase simulation;

  _SimulationPainter(this.simulation);

  @override
  void paint(Canvas canvas, Size size) {
    simulation.render(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _SimulationPainter old) => true;
}
