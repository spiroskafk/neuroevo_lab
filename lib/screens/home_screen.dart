import 'package:flutter/material.dart';
import '../models/simulation_meta.dart';
import '../widgets/simulation_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final simulations = SimulationMeta.all();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F23),
        elevation: 0,
        title: const Row(
          children: [
            Text('🧬', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'NeuroEvo Lab',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Simulations',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: simulations.length,
                itemBuilder: (context, index) {
                  final sim = simulations[index];
                  return SimulationCard(
                    meta: sim,
                    onTap: () {
                      if (sim.status == SimulationStatus.available) {
                        Navigator.pushNamed(
                          context,
                          '/simulation',
                          arguments: sim.id,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
