import 'package:flutter/material.dart';
import '../core/neat/genome.dart';
import '../core/neat/neuron.dart';

class NeuralNetworkPainter extends CustomPainter {
  final Genome genome;

  NeuralNetworkPainter({required this.genome});

  @override
  void paint(Canvas canvas, Size size) {
    if (genome.neurons.isEmpty) return;

    _drawBackground(canvas, size);

    final positions = _computePositions(size);
    _drawConnections(canvas, positions);
    _drawNeurons(canvas, positions);
  }

  Map<int, Offset> _computePositions(Size size) {
    final inputs = genome.neurons.where((n) => n.type == NeuronType.bias || n.type == NeuronType.input).toList();
    final hidden = genome.neurons.where((n) => n.type == NeuronType.hidden).toList();
    final outputs = genome.neurons.where((n) => n.type == NeuronType.output).toList();

    final margin = 40.0;
    final leftX = margin;
    final rightX = size.width - margin;
    final centerX = size.width / 2;

    final positions = <int, Offset>{};

    double colY(int idx, int total, double h) {
      if (total == 1) return h / 2;
      return (idx + 0.5) * h / total;
    }

    final h = size.height;

    for (int i = 0; i < inputs.length; i++) {
      positions[inputs[i].id] = Offset(leftX, colY(i, inputs.length, h));
    }
    for (int i = 0; i < outputs.length; i++) {
      positions[outputs[i].id] = Offset(rightX, colY(i, outputs.length, h));
    }

    if (hidden.isNotEmpty) {
      for (int i = 0; i < hidden.length; i++) {
        // spread hidden in middle, with offset if multiple columns
        final x = centerX;
        positions[hidden[i].id] = Offset(x, colY(i, hidden.length, h));
      }
    }

    return positions;
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xCC0F0F23);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final borderPaint = Paint()
      ..color = const Color(0xFF333355)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(Rect.fromLTWH(1, 1, size.width - 2, size.height - 2), borderPaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'Neural Network',
        style: TextStyle(color: Colors.white54, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width - tp.width - 8, 4));
  }

  void _drawConnections(Canvas canvas, Map<int, Offset> positions) {
    final disabledPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..strokeWidth = 0.5;

    for (final c in genome.connections) {
      final fromPos = positions[c.from];
      final toPos = positions[c.to];
      if (fromPos == null || toPos == null) continue;

      if (!c.enabled) {
        canvas.drawLine(fromPos, toPos, disabledPaint);
        continue;
      }

      final weight = c.weight;
      final thickness = (weight.abs() * 2.0).clamp(0.5, 4.0);
      final opacity = weight.abs().clamp(0.1, 1.0);

      final paint = Paint()
        ..color = (weight >= 0
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE53935))
            .withValues(alpha: opacity)
        ..strokeWidth = thickness
        ..style = PaintingStyle.stroke;

      canvas.drawLine(fromPos, toPos, paint);
    }
  }

  void _drawNeurons(Canvas canvas, Map<int, Offset> positions) {
    final nodeRadius = 8.0;

    for (final n in genome.neurons) {
      final pos = positions[n.id];
      if (pos == null) continue;

      final value = n.value;

      final Color fill;
      if (n.type == NeuronType.bias) {
        fill = const Color(0xFF9C27B0);
      } else if (value >= 0) {
        final intensity = (value * 255).round().clamp(0, 255);
        fill = Color.fromARGB(255, 0, intensity, 0);
      } else {
        final intensity = ((-value) * 255).round().clamp(0, 255);
        fill = Color.fromARGB(255, intensity, 0, 0);
      }

      final border = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      final fillPaint = Paint()..color = fill;

      canvas.drawCircle(pos, nodeRadius, fillPaint);
      canvas.drawCircle(pos, nodeRadius, border);

      final tp = TextPainter(
        text: TextSpan(
          text: n.type == NeuronType.bias
              ? 'B'
              : n.type == NeuronType.input
                  ? 'I'
                  : n.type == NeuronType.output
                      ? 'O'
                      : 'H',
          style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant NeuralNetworkPainter old) => true;
}
