import 'package:flutter/material.dart';

import 'package:src/core/theme/app_colors.dart';

class ModeChip extends StatelessWidget {
  const ModeChip({
    required this.label,
    required this.isSelected,
    super.key,
  });

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
