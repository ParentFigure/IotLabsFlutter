import 'package:flutter/material.dart';
import 'package:src/core/theme/app_colors.dart';

class SensorCard extends StatelessWidget {
  const SensorCard({
    required this.lux,
    required this.status,
    super.key,
  });

  final double lux;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.wb_sunny_outlined,
              color: AppColors.accent,
              size: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Light sensor',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Current brightness: ${lux.toStringAsFixed(1)} lx',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(status, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}
