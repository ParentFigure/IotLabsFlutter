import 'package:flutter/material.dart';

class SensitivityCard extends StatelessWidget {
  const SensitivityCard({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensor sensitivity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Lower value reacts later, higher value turns the lamp '
              'on earlier.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Slider(
              value: value,
              min: 10,
              max: 100,
              divisions: 9,
              label: value.round().toString(),
              onChanged: onChanged,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${value.round()}%',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
