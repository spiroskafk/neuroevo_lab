import 'package:flutter/material.dart';
import '../models/simulation_meta.dart';

class SimulationCard extends StatelessWidget {
  final SimulationMeta meta;
  final VoidCallback onTap;

  const SimulationCard({
    super.key,
    required this.meta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = meta.status == SimulationStatus.locked;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isLocked ? 1 : 3,
      color: isLocked ? Colors.grey[900] : meta.color.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: meta.color.withValues(alpha: isLocked ? 0.2 : 0.4),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                meta.icon,
                size: 40,
                color: isLocked
                    ? Colors.grey[600]
                    : meta.color,
              ),
              const SizedBox(height: 8),
              Text(
                meta.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? Colors.grey[600] : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                meta.algorithm,
                style: TextStyle(
                  fontSize: 11,
                  color: isLocked ? Colors.grey[700] : Colors.grey[400],
                ),
              ),
              if (isLocked) ...[
                const SizedBox(height: 8),
                Icon(Icons.lock, size: 16, color: Colors.grey[700]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
