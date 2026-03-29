import 'package:flutter/material.dart';
import 'package:src/core/theme/app_colors.dart';

class LampStatusCard extends StatefulWidget {
  const LampStatusCard({super.key});

  @override
  State<LampStatusCard> createState() => _LampStatusCardState();
}

class _LampStatusCardState extends State<LampStatusCard> {
  bool _isLampOn = true;

  void _toggleLamp() {
    setState(() {
      _isLampOn = !_isLampOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineMedium;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 72,
                  backgroundColor: AppColors.accent,
                  child: Icon(
                    Icons.lightbulb_rounded,
                    size: 72,
                    color: _isLampOn ? Colors.black : AppColors.cardLight,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isLampOn ? 'Lamp is ON' : 'Lamp is OFF',
                  textAlign: TextAlign.center,
                  style: titleStyle,
                ),
                if (!isNarrow) ...[
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
                    onPressed: _toggleLamp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      _isLampOn ? 'Turn OFF' : 'Turn ON',
                    ),
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
