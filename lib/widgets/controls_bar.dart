import 'package:flutter/material.dart';
import '../simulations/base/evolution_state.dart';

class ControlsBar extends StatelessWidget {
  final EvolutionState state;
  final VoidCallback onToggleRunning;
  final VoidCallback onReset;
  final VoidCallback? onShowAnalysis;
  final VoidCallback? onToggleNetwork;
  final void Function(double) onSpeedChange;

  const ControlsBar({
    super.key,
    required this.state,
    required this.onToggleRunning,
    required this.onReset,
    this.onShowAnalysis,
    this.onToggleNetwork,
    required this.onSpeedChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1A1A2E),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              state.isRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: onToggleRunning,
          ),
          const SizedBox(width: 8),
          ..._speedButtons(),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.hub,
              color: state.showNetwork ? const Color(0xFF4CAF50) : Colors.white54,
            ),
            onPressed: onToggleNetwork,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white54),
            onPressed: onShowAnalysis,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: onReset,
          ),
        ],
      ),
    );
  }

  List<Widget> _speedButtons() {
    final speeds = [1.0, 2.0, 5.0];
    return speeds.map((speed) {
      final isActive = state.speedMultiplier == speed;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            backgroundColor: isActive
                ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isActive
                  ? const BorderSide(color: Color(0xFF4CAF50))
                  : BorderSide.none,
            ),
          ),
          onPressed: () => onSpeedChange(speed),
          child: Text(
            '${speed.toInt()}x',
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xFF4CAF50) : Colors.grey[400],
            ),
          ),
        ),
      );
    }).toList();
  }
}
