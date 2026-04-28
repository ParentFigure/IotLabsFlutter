import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/home/presentation/widgets/auto_control_card.dart';
import 'package:src/features/home/presentation/widgets/broker_card.dart';
import 'package:src/features/home/presentation/widgets/lamp_status_card.dart';
import 'package:src/features/home/presentation/widgets/schedule_editor_dialog.dart';
import 'package:src/features/home/presentation/widgets/schedule_tile.dart';
import 'package:src/features/home/presentation/widgets/sensitivity_card.dart';
import 'package:src/features/home/presentation/widgets/sensor_card.dart';
import 'package:src/features/lamp/domain/schedule_entry.dart';
import 'package:src/features/lamp/presentation/lamp_controller.dart';
import 'package:src/features/profile/presentation/profile_page.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/section_title.dart';

class StatusSection extends StatelessWidget {
  const StatusSection({required this.sensorLabel, super.key});

  final String sensorLabel;

  @override
  Widget build(BuildContext context) {
    final lamp = context.watch<LampController>();
    final state = lamp.state;
    return Column(
      children: <Widget>[
        BrokerCard(
          host: state.broker,
          port: state.port,
          topicPrefix: state.topicPrefix,
          isConnected: lamp.isBrokerConnected,
          isConnecting: lamp.isMqttConnecting,
          onReconnect: lamp.connectMqtt,
        ),
        const SizedBox(height: 16),
        LampStatusCard(
          isLampOn: state.isLampOn,
          onToggle: () => lamp.setManualLamp(!state.isLampOn),
        ),
        const SizedBox(height: 16),
        SensorCard(lux: state.sensorLux, status: sensorLabel),
        const SizedBox(height: 16),
        SensitivityCard(
          value: state.sensitivity,
          onChanged: lamp.setSensitivity,
        ),
        const SizedBox(height: 16),
        AutoControlCard(isEnabled: state.autoMode, onChanged: lamp.setAutoMode),
      ],
    );
  }
}

class ScheduleSection extends StatelessWidget {
  const ScheduleSection({
    required this.schedules,
    required this.isOnline,
    required this.email,
    super.key,
  });

  final List<ScheduleEntry> schedules;
  final bool isOnline;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final lamp = context.watch<LampController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionTitle(
          title: 'Weekly schedule',
          subtitle: email == null
              ? 'Add, edit and delete weekly lamp actions here.'
              : 'Manage weekly lamp actions for $email',
        ),
        const SizedBox(height: 12),
        if (!isOnline)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Internet is offline. MQTT updates are limited.'),
            ),
          ),
        if (lamp.message != null) ...<Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(lamp.message!),
              trailing: IconButton(
                onPressed: lamp.clearMessage,
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        for (final ScheduleEntry item in schedules)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ScheduleTile(
              day: item.day,
              time: item.time,
              action: item.action,
              onEdit: () => _saveSchedule(context, lamp, entry: item),
              onDelete: () => lamp.deleteSchedule(item.id),
            ),
          ),
        AppButton(
          title: 'Add schedule',
          icon: Icons.add_rounded,
          onPressed: () => _saveSchedule(context, lamp),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, ProfilePage.routeName),
          icon: const Icon(Icons.person_outline_rounded),
          label: const Text('Open profile'),
        ),
      ],
    );
  }

  Future<void> _saveSchedule(
    BuildContext context,
    LampController lamp, {
    ScheduleEntry? entry,
  }) async {
    final ScheduleEntry? result = await openScheduleEditor(
      context,
      entry: entry,
    );
    if (result != null) {
      await lamp.upsertSchedule(result);
    }
  }
}
