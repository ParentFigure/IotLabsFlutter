import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:src/features/auth/data/auth_repository_impl.dart';
import 'package:src/features/auth/domain/auth_repository.dart';
import 'package:src/features/auth/domain/user.dart';
import 'package:src/features/home/presentation/widgets/auto_control_card.dart';
import 'package:src/features/home/presentation/widgets/broker_card.dart';
import 'package:src/features/home/presentation/widgets/lamp_status_card.dart';
import 'package:src/features/home/presentation/widgets/schedule_tile.dart';
import 'package:src/features/home/presentation/widgets/sensitivity_card.dart';
import 'package:src/features/home/presentation/widgets/sensor_card.dart';
import 'package:src/features/lamp/domain/schedule_entry.dart';
import 'package:src/features/lamp/presentation/lamp_controller.dart';
import 'package:src/features/profile/presentation/profile_page.dart';
import 'package:src/shared/connectivity/network_controller.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/section_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthRepository _authRepository = AuthRepositoryImpl();
  User? _user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LampController>().initialize();
      _loadUser();
    });
  }

  Future<void> _loadUser() async {
    final User? currentUser = await _authRepository.getCurrentUser();
    if (!mounted) {
      return;
    }

    setState(() {
      _user = currentUser;
    });
  }

  Future<void> _logOut() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to leave the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _authRepository.logout();
    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  List<ScheduleEntry> _sortedSchedules(List<ScheduleEntry> schedules) {
    final List<ScheduleEntry> items = List<ScheduleEntry>.from(schedules);
    items.sort(_compareSchedules);
    return items;
  }

  int _compareSchedules(ScheduleEntry a, ScheduleEntry b) {
    final int dayDiff = _dayIndex(a.day).compareTo(_dayIndex(b.day));
    if (dayDiff != 0) {
      return dayDiff;
    }
    return a.time.compareTo(b.time);
  }

  int _dayIndex(String day) {
    return ScheduleEntry.days.indexOf(day);
  }

  TimeOfDay _parseTime(String value) {
    final List<String> parts = value.split(':');
    final int hour = int.tryParse(parts.first) ?? 0;
    final int minute = int.tryParse(parts.last) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay value) {
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _openScheduleEditor({
    required LampController controller,
    ScheduleEntry? entry,
  }) async {
    final TimeOfDay initialTime = entry == null
        ? const TimeOfDay(hour: 6, minute: 30)
        : _parseTime(entry.time);
    TimeOfDay selectedTime = initialTime;
    String selectedAction = entry?.action ?? 'ON';
    String selectedDay = entry?.day ?? ScheduleEntry.days.first;

    final ScheduleEntry? result = await showDialog<ScheduleEntry>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: Text(entry == null ? 'Add schedule' : 'Edit schedule'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    initialValue: selectedDay,
                    items: ScheduleEntry.days
                        .map(
                          (String day) => DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) {
                      setModalState(() {
                        selectedDay = value ?? ScheduleEntry.days.first;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Day'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Time'),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time_rounded),
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );

                      if (pickedTime == null) {
                        return;
                      }

                      setModalState(() {
                        selectedTime = pickedTime;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedAction,
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem(value: 'ON', child: Text('ON')),
                      DropdownMenuItem(value: 'OFF', child: Text('OFF')),
                    ],
                    onChanged: (String? value) {
                      setModalState(() {
                        selectedAction = value ?? 'ON';
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Action'),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      ScheduleEntry(
                        id: entry?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        day: selectedDay,
                        time: _formatTime(selectedTime),
                        action: selectedAction,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    final List<ScheduleEntry> schedules =
        List<ScheduleEntry>.from(controller.state.schedules);
    final int index =
        schedules.indexWhere((ScheduleEntry item) => item.id == result.id);

    if (index == -1) {
      schedules.add(result);
    } else {
      schedules[index] = result;
    }

    schedules.sort(_compareSchedules);
    await controller.saveSchedules(schedules);
  }

  Future<void> _deleteSchedule(LampController controller, String id) async {
    final List<ScheduleEntry> schedules = controller.state.schedules
        .where((ScheduleEntry item) => item.id != id)
        .toList();
    await controller.saveSchedules(schedules);
  }

  @override
  Widget build(BuildContext context) {
    final LampController controller = context.watch<LampController>();
    final bool isOnline = context.watch<NetworkController>().isOnline;
    final state = controller.state;

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String sensorLabel = state.sensorLux < state.sensitivity
        ? 'Dark'
        : 'Bright';
    final List<ScheduleEntry> schedules = _sortedSchedules(state.schedules);
    final double width = MediaQuery.sizeOf(context).width;
    final bool isWide = width >= 760;

    final List<Widget> firstColumn = <Widget>[
      BrokerCard(
        host: state.broker,
        port: state.port,
        topicPrefix: state.topicPrefix,
        isConnected: controller.isBrokerConnected,
        isConnecting: controller.isMqttConnecting,
        onReconnect: controller.connectMqtt,
      ),
      const SizedBox(height: 16),
      LampStatusCard(
        isLampOn: state.isLampOn,
        onToggle: () {
          controller.setManualLamp(!state.isLampOn);
        },
      ),
      const SizedBox(height: 16),
      SensorCard(lux: state.sensorLux, status: sensorLabel),
      const SizedBox(height: 16),
      SensitivityCard(
        value: state.sensitivity,
        onChanged: controller.setSensitivity,
      ),
      const SizedBox(height: 16),
      AutoControlCard(
        isEnabled: state.autoMode,
        onChanged: controller.setAutoMode,
      ),
    ];

    final List<Widget> secondColumn = <Widget>[
      SectionTitle(
        title: 'Weekly schedule',
        subtitle: _user == null
            ? 'Add, edit and delete weekly lamp actions here.'
            : 'Manage weekly lamp actions for ${_user!.email}',
      ),
      const SizedBox(height: 12),
      if (!isOnline)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Internet is offline. MQTT updates are limited.'),
          ),
        ),
      if (controller.message != null) ...<Widget>[
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(controller.message!),
            trailing: IconButton(
              onPressed: controller.clearMessage,
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
      if (schedules.isEmpty)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Text('No schedule yet. Add the first time slot.'),
          ),
        )
      else
        ...schedules.map(
          (ScheduleEntry item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ScheduleTile(
              day: item.day,
              time: item.time,
              action: item.action,
              onEdit: () {
                _openScheduleEditor(controller: controller, entry: item);
              },
              onDelete: () {
                _deleteSchedule(controller, item.id);
              },
            ),
          ),
        ),
      const SizedBox(height: 8),
      AppButton(
        title: 'Add schedule',
        icon: Icons.add_rounded,
        onPressed: () {
          _openScheduleEditor(controller: controller);
        },
      ),
    ];

    final Widget content = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: Column(children: firstColumn)),
              const SizedBox(width: 16),
              Expanded(child: Column(children: secondColumn)),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ...firstColumn,
              const SizedBox(height: 24),
              ...secondColumn,
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lamp'),
        actions: <Widget>[
          if (_user != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  _user!.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, ProfilePage.routeName);
              await _loadUser();
            },
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            onPressed: _logOut,
            icon: const Icon(Icons.logout_rounded),
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
