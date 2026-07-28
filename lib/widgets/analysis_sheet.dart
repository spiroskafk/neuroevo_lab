import 'package:flutter/material.dart';
import '../simulations/base/evolution_state.dart';

class AnalysisSheet extends StatelessWidget {
  final EvolutionState state;

  const AnalysisSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text(
              'Analysis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Species'),
                      Tab(text: 'Complexity'),
                      Tab(text: 'Details'),
                    ],
                    labelColor: Color(0xFF4CAF50),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF4CAF50),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _SpeciesTab(state: state),
                        _ComplexityTab(state: state),
                        _DetailsTab(state: state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeciesTab extends StatelessWidget {
  final EvolutionState state;
  const _SpeciesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (_, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: CustomPaint(
          size: const Size(double.infinity, 220),
          painter: _LineChartPainter(
            values: state.speciesCountHistory,
            color: const Color(0xFF9C27B0),
            label: 'Species',
          ),
        ),
      ),
    );
  }
}

class _ComplexityTab extends StatelessWidget {
  final EvolutionState state;
  const _ComplexityTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (_, _) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _MultiLineChartPainter(
                  series: [
                    _LineSeries(
                      values: state.neuronCountHistory,
                      color: const Color(0xFF2196F3),
                      label: 'Neurons',
                    ),
                    _LineSeries(
                      values: state.connectionCountHistory,
                      color: const Color(0xFFFF9800),
                      label: 'Connections',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(const Color(0xFF2196F3), 'Neurons'),
                const SizedBox(width: 16),
                _legendDot(const Color(0xFFFF9800), 'Connections'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final EvolutionState state;
  const _DetailsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (_, _) {
        final details = state.currentSpeciesDetails;
        if (details.isEmpty) {
          return const Center(child: Text('No data', style: TextStyle(color: Colors.grey)));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: details.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF333355))),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 30, child: Text('ID', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Size', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(child: Text('Best', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold))),
                  ],
                ),
              );
            }
            final d = details[i - 1];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: const Color(0xFF333355).withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${d['id']}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${d['count']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      (d['fitness'] as double) > -1e9
                          ? (d['fitness'] as double).toStringAsFixed(0)
                          : '-',
                      style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 12),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Widget _legendDot(Color color, String label) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
    ],
  );
}

class _LineChartPainter extends CustomPainter {
  final List<int> values;
  final Color color;
  final String label;

  _LineChartPainter({required this.values, required this.color, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      _drawEmpty(canvas, size);
      return;
    }

    final maxVal = values.fold(0.0, (p, v) => v > p ? v.toDouble() : p);
    if (maxVal <= 0) return;

    _drawGrid(canvas, size, maxVal);

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

    final tp = TextPainter(
      text: TextSpan(
        text: '$label: ${values.last}',
        style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(2, 2));
  }

  void _drawGrid(Canvas canvas, Size size, double maxVal) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A3E)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawEmpty(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF16213E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) => true;
}

class _LineSeries {
  final List<int> values;
  final Color color;
  final String label;

  _LineSeries({required this.values, required this.color, required this.label});
}

class _MultiLineChartPainter extends CustomPainter {
  final List<_LineSeries> series;

  _MultiLineChartPainter({required this.series});

  @override
  void paint(Canvas canvas, Size size) {
    final allValues = series.expand((s) => s.values);
    if (allValues.isEmpty) return;

    final maxVal = allValues.fold(0.0, (p, v) => v > p ? v.toDouble() : p);
    if (maxVal <= 0) return;

    _drawGrid(canvas, size);

    for (final s in series) {
      if (s.values.length < 2) continue;

      final paint = Paint()
        ..color = s.color.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final path = Path();
      final stepX = size.width / (s.values.length - 1);

      for (int i = 0; i < s.values.length; i++) {
        final x = i * stepX;
        final y = size.height - (s.values[i] / maxVal * size.height);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A3E)
      ..strokeWidth = 0.5;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final bgPaint = Paint()..color = const Color(0xFF16213E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
  }

  @override
  bool shouldRepaint(covariant _MultiLineChartPainter old) => true;
}
