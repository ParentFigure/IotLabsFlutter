import 'package:flutter/material.dart';
import 'package:src/features/home/presentation/widgets/schedule_tile.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/section_title.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  static const routeName = '/schedule';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionTitle(
                  title: 'Lighting schedule',
                  subtitle: 'The user chooses time slots'
                   ' for the lamp.',
                ),
                const SizedBox(height: 20),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Mon')),
                    Chip(label: Text('Tue')),
                    Chip(label: Text('Wed')),
                    Chip(label: Text('Thu')),
                    Chip(label: Text('Fri')),
                    Chip(label: Text('Sat')),
                    Chip(label: Text('Sun')),
                  ],
                ),
                const SizedBox(height: 20),
                const ScheduleTile(time: '06:30', action: 'ON'),
                const SizedBox(height: 12),
                const ScheduleTile(time: '09:00', action: 'OFF'),
                const SizedBox(height: 12),
                const ScheduleTile(time: '18:40', action: 'ON'),
                const SizedBox(height: 12),
                const ScheduleTile(time: '22:00', action: 'OFF'),
                const SizedBox(height: 20),
                AppButton(
                  title: 'Add time slot',
                  icon: Icons.add_rounded,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
