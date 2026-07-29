import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../simulations/base/simulation.dart';
import '../simulations/base/evolution_state.dart';
import '../simulations/self_driving/car_simulation.dart';
import '../simulations/flappy_bird/flappy_simulation.dart';
import '../simulations/predator_prey/predator_prey_simulation.dart';
import '../models/simulation_meta.dart';
import '../core/neat/genome.dart';
import '../core/neat/neuron.dart';
import '../widgets/simulation_canvas.dart';
import '../widgets/controls_bar.dart';
import '../widgets/info_overlay.dart';
import '../widgets/fitness_graph.dart';
import '../widgets/analysis_sheet.dart';
import '../widgets/neural_network_painter.dart';

class SimulationScreen extends StatefulWidget {
  final String simulationId;

  const SimulationScreen({super.key, required this.simulationId});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with SingleTickerProviderStateMixin {
  late SimulationBase _simulation;
  Ticker? _ticker;
  Duration _previousElapsed = Duration.zero;
  double _accumulator = 0;
  static const double _fixedDt = 1 / 60;

  EvolutionState get _state => _simulation.state;

  static final _emptyGenome = Genome(
    id: -1,
    neurons: [
      Neuron(id: 0, type: NeuronType.bias),
      Neuron(id: 1, type: NeuronType.input),
      Neuron(id: 2, type: NeuronType.output),
    ],
    connections: [],
  );

  @override
  void initState() {
    super.initState();
    _simulation = _createSimulation();
    _simulation.init();
    _startLoop();
  }

  SimulationBase _createSimulation() {
    switch (widget.simulationId) {
      case 'self_driving':
        return CarSimulation();
      case 'flappy_bird':
        return FlappyBirdSimulation();
      case 'predator_prey':
        return PredatorPreySimulation();
      default:
        return CarSimulation();
    }
  }

  void _startLoop() {
    _previousElapsed = Duration.zero;
    _ticker = createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration elapsed) {
    final rawDt = (elapsed - _previousElapsed).inMicroseconds / 1000000;
    _previousElapsed = elapsed;

    final dt = rawDt.clamp(0, 0.05);
    _accumulator += dt * _state.speedMultiplier;

    while (_accumulator >= _fixedDt) {
      _simulation.update(_fixedDt);
      _accumulator -= _fixedDt;
    }

    if (mounted) setState(() {});
  }

  void _showAnalysis(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AnalysisSheet(state: _state),
    );
  }

  @override
  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
    _simulation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = SimulationMeta.all().firstWhere(
      (m) => m.id == widget.simulationId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(meta.icon, color: meta.color, size: 20),
            const SizedBox(width: 8),
            Text(
              meta.title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ListenableBuilder(
              listenable: _state,
              builder: (_, _) => InfoOverlay(state: _state),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                SimulationCanvas(simulation: _simulation),
                if (_state.showNetwork)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: NeuralNetworkPainter(
                          genome: _simulation.population?.bestGenome ??
                              _emptyGenome,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ControlsBar(
            state: _state,
            onToggleRunning: _simulation.toggleRunning,
            onReset: () => _simulation.reset(),
            onShowAnalysis: () => _showAnalysis(context),
            onToggleNetwork: _state.toggleNetwork,
            onSpeedChange: (speed) => _simulation.setSpeed(speed),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListenableBuilder(
              listenable: _state,
              builder: (_, _) => FitnessGraph(state: _state),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
