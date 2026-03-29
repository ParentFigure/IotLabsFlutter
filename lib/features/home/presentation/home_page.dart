import 'package:flutter/material.dart';
import 'package:src/features/home/presentation/widgets/auto_control_card.dart';
import 'package:src/features/home/presentation/widgets/lamp_status_card.dart';
import 'package:src/features/home/presentation/widgets/schedule_tile.dart';
import 'package:src/features/home/presentation/widgets/sensitivity_card.dart';
import 'package:src/features/home/presentation/widgets/sensor_card.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/section_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _sensitivity = 60;
  bool _autoMode = true;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 760;

    final firstColumn = <Widget>[
      const LampStatusCard(),
      const SizedBox(height: 16),
      const SensorCard(),
      const SizedBox(height: 16),
      SensitivityCard(
        value: _sensitivity,
        onChanged: (value) {
          setState(() {
            _sensitivity = value;
          });
        },
      ),
    ];

    final secondColumn = <Widget>[
      AutoControlCard(
        isEnabled: _autoMode,
        onChanged: (value) {
          setState(() {
            _autoMode = value;
          });
        },
      ),
      const SizedBox(height: 24),
      const SectionTitle(
        title: 'User schedule',
        subtitle: 'Set the lighting hours.',
      ),
      const SizedBox(height: 12),
      const ScheduleTile(time: '06:30', action: 'ON'),
      const SizedBox(height: 12),
      const ScheduleTile(time: '09:00', action: 'OFF'),
      const SizedBox(height: 12),
      const ScheduleTile(time: '18:40', action: 'ON'),
      const SizedBox(height: 12),
      const ScheduleTile(time: '22:00', action: 'OFF'),
      const SizedBox(height: 16),
      AppButton(
        title: 'Schedule settings',
        icon: Icons.calendar_month_outlined,
        onPressed: () {
          Navigator.pushNamed(context, '/schedule');
        },
      ),
    ];

    final content = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(children: firstColumn)),
              const SizedBox(width: 16),
              Expanded(child: Column(children: secondColumn)),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...firstColumn,
              const SizedBox(height: 24),
              ...secondColumn,
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lamp'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: content,
        ),
      ),
    );
  }
}
