import 'package:flutter/material.dart';

class AutoControlCard extends StatelessWidget {
  const AutoControlCard({
    required this.isEnabled,
    required this.onChanged,
    super.key,
  });

  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto mode',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Light sensor status.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Switch(value: isEnabled, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
