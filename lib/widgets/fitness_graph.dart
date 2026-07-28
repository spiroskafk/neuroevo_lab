import 'package:flutter/material.dart';
import '../simulations/base/evolution_state.dart';

class FitnessGraph extends StatelessWidget {
  final EvolutionState state;

  const FitnessGraph({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        size: Size.infinite,
        painter: _FitnessGraphPainter(state: state),
      ),
    );
  }
}

class _FitnessGraphPainter extends CustomPainter {
  final EvolutionState state;

  _FitnessGraphPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    if (state.bestFitnessHistory.isEmpty) return;

    final bgPaint = Paint()..color = const Color(0xFF16213E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      bgPaint,
    );

    final maxFitness = state.bestFitnessHistory
        .fold(0.0, (prev, v) => v > prev ? v : prev);
    if (maxFitness <= 0) return;

    final bestValues = state.bestFitnessHistory;
    final avgValues = state.averageFitnessHistory;

    _drawLine(canvas, size, bestValues, maxFitness, const Color(0xFF4CAF50));
    _drawLine(canvas, size, avgValues, maxFitness, const Color(0xFF2196F3));
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> values,
    double maxVal,
    Color color,
  ) {
    if (values.length < 2) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxVal * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FitnessGraphPainter old) => true;
}
