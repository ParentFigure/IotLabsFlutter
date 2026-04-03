import 'package:flutter/material.dart';
import 'package:src/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.title,
    required this.onPressed,
    super.key,
    this.icon,
  });

  final String title;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = icon == null
        ? const SizedBox.shrink()
        : Icon(icon, size: 20, color: Colors.black);

    return SizedBox(
      height: 64,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }
}
