import 'package:flutter/material.dart';
import 'package:src/core/theme/app_colors.dart';

class ScheduleTile extends StatelessWidget {
  const ScheduleTile({
    required this.day,
    required this.time,
    required this.action,
    super.key,
    this.onEdit,
    this.onDelete,
  });

  final String day;
  final String time;
  final String action;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final Color actionColor = action == 'ON'
        ? AppColors.success
        : AppColors.textSecondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            const Icon(Icons.access_time_rounded, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(day, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(time, style: Theme.of(context).textTheme.titleLarge),
                ],
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
            const SizedBox(width: 8),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            if (onDelete != null)
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ],
        ),
      ),
    );
  }
}
