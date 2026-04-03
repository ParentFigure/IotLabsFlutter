import 'package:flutter/material.dart';
import 'package:src/core/theme/app_colors.dart';

class LampStatusCard extends StatelessWidget {
  const LampStatusCard({
    required this.isLampOn,
    required this.onToggle,
    super.key,
  });

  final bool isLampOn;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleStyle = Theme.of(context).textTheme.headlineMedium;
    final TextStyle? bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isNarrow = constraints.maxWidth < 360;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 72,
                  backgroundColor: AppColors.accent,
                  child: Icon(
                    Icons.lightbulb_rounded,
                    size: 72,
                    color: isLampOn ? Colors.black : AppColors.cardLight,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isLampOn ? 'Lamp is ON' : 'Lamp is OFF',
                  textAlign: TextAlign.center,
                  style: titleStyle,
                ),
                if (!isNarrow) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    'Lighting for seedlings',
                    textAlign: TextAlign.center,
                    style: bodyStyle,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onToggle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(isLampOn ? 'Turn OFF' : 'Turn ON'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
