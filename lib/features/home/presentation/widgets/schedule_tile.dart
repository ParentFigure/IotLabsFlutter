import 'package:flutter/material.dart';
import 'package:src/core/theme/app_colors.dart';

class ScheduleTile extends StatelessWidget {
  const ScheduleTile({
    required this.time,
    required this.action,
    super.key,
  });

  final String time;
  final String action;

  @override
  Widget build(BuildContext context) {
    final actionColor = action == 'ON'
        ? AppColors.success
        : AppColors.textSecondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                time,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(
              action,
              style: TextStyle(
                color: actionColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
