import 'package:flutter/material.dart';
import '../simulations/base/evolution_state.dart';

class FitnessGraph extends StatelessWidget {
  final EvolutionState state;

  const FitnessGraph({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
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
    _drawBackground(canvas, size);

    if (state.bestFitnessHistory.isEmpty) return;

    final maxVal = state.bestFitnessHistory
        .fold(0.0, (prev, v) => v > prev ? v : prev);
    if (maxVal <= 0) return;

    _drawTargetLine(canvas, size, maxVal);
    _drawYLabels(canvas, size, maxVal);
    _drawLine(canvas, size, state.bestFitnessHistory, maxVal, const Color(0xFF4CAF50));
    _drawLine(canvas, size, state.averageFitnessHistory, maxVal, const Color(0xFF2196F3));
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF16213E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      bgPaint,
    );
  }

  void _drawTargetLine(Canvas canvas, Size size, double maxVal) {
    const target = 1000.0;
    if (maxVal < target) {
      final y = size.height - (target / maxVal * size.height);
      if (y > 0) {
        final paint = Paint()
          ..color = const Color(0x44FFD700)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

        final tp = TextPainter(
          text: TextSpan(
            text: '1 lap',
            style: TextStyle(color: Colors.amber.withValues(alpha: 0.5), fontSize: 9),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(2, y - tp.height - 2));
      }
    }
  }

  void _drawYLabels(Canvas canvas, Size size, double maxVal) {
    final genCount = state.bestFitnessHistory.length;
    if (genCount < 2) return;

    final tp = TextPainter(
      text: TextSpan(
        text: 'G${state.generation}',
        style: const TextStyle(color: Colors.grey, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width - tp.width - 4, size.height - tp.height - 2));
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
