import 'package:flutter/material.dart';

enum SimulationStatus { available, locked }

class SimulationMeta {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final SimulationStatus status;
  final String algorithm;

  const SimulationMeta({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.status = SimulationStatus.available,
    this.algorithm = 'NEAT',
  });

  static List<SimulationMeta> all() => [
        const SimulationMeta(
          id: 'self_driving',
          title: 'Self-driving Cars',
          description: 'Cars learn to navigate a track using NEAT neural networks',
          icon: Icons.directions_car,
          color: Color(0xFF4CAF50),
          algorithm: 'NEAT',
        ),
        const SimulationMeta(
          id: 'flappy_bird',
          title: 'Flappy Bird AI',
          description: 'Watch birds evolve to master Flappy Bird',
          icon: Icons.auto_awesome,
          color: Color(0xFFFF9800),
          algorithm: 'NEAT',
          status: SimulationStatus.locked,
        ),
        const SimulationMeta(
          id: 'smart_rockets',
          title: 'Smart Rockets',
          description: 'Rockets evolve to reach a target avoiding obstacles',
          icon: Icons.rocket_launch,
          color: Color(0xFFF44336),
          algorithm: 'Genetic Algorithm',
          status: SimulationStatus.locked,
        ),
        const SimulationMeta(
          id: 'maze_solver',
          title: 'Maze Solver',
          description: 'Agents learn to navigate complex mazes',
          icon: Icons.grid_on,
          color: Color(0xFF9C27B0),
          algorithm: 'NEAT / Q-Learning',
          status: SimulationStatus.locked,
        ),
        const SimulationMeta(
          id: 'cartpole',
          title: 'CartPole',
          description: 'Balance a pole on a moving cart with neural networks',
          icon: Icons.balance,
          color: Color(0xFF2196F3),
          algorithm: 'NEAT',
          status: SimulationStatus.locked,
        ),
        const SimulationMeta(
          id: 'soccer',
          title: 'Soccer',
          description: 'Multi-agent teams learn to play soccer together',
          icon: Icons.sports_soccer,
          color: Color(0xFF00BCD4),
          algorithm: 'Multi-agent NEAT',
          status: SimulationStatus.locked,
        ),
      ];
}
