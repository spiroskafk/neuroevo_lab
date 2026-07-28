import 'dart:async';
import 'package:flutter/material.dart';
import '../simulations/base/simulation.dart';
import '../simulations/base/evolution_state.dart';
import '../simulations/self_driving/car_simulation.dart';
import '../models/simulation_meta.dart';
import '../widgets/simulation_canvas.dart';
import '../widgets/controls_bar.dart';
import '../widgets/info_overlay.dart';
import '../widgets/fitness_graph.dart';

class SimulationScreen extends StatefulWidget {
  final String simulationId;

  const SimulationScreen({super.key, required this.simulationId});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen>
    with SingleTickerProviderStateMixin {
  late SimulationBase _simulation;
  Timer? _timer;
  double _lastTime = 0;
  bool _initialized = false;

  EvolutionState get _state => _simulation.state;

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
      default:
        return CarSimulation();
    }
  }

  void _startLoop() {
    const targetDt = 1 / 60;
    _lastTime = DateTime.now().microsecondsSinceEpoch / 1000000;
    _timer = Timer.periodic(
      Duration(milliseconds: (targetDt * 1000).round()),
      (_) {
        final now = DateTime.now().microsecondsSinceEpoch / 1000000;
        var dt = now - _lastTime;
        _lastTime = now;

        dt *= _state.speedMultiplier;
        dt = dt.clamp(0, 0.05);

        _simulation.update(dt);
        if (mounted) setState(() {});
        if (!_initialized) {
          _initialized = true;
          _state.toggleRunning();
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
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
          SimulationCanvas(simulation: _simulation),
          ControlsBar(
            state: _state,
            onToggleRunning: _simulation.toggleRunning,
            onReset: () {
              _simulation.reset();
              _initialized = false;
            },
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
