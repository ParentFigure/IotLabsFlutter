import 'package:flutter/material.dart';
import 'package:src/features/auth/data/auth_repository_impl.dart';
import 'package:src/features/auth/domain/auth_repository.dart';
import 'package:src/features/auth/domain/user.dart';
import 'package:src/features/home/presentation/widgets/auto_control_card.dart';
import 'package:src/features/home/presentation/widgets/lamp_status_card.dart';
import 'package:src/features/home/presentation/widgets/schedule_tile.dart';
import 'package:src/features/home/presentation/widgets/sensitivity_card.dart';
import 'package:src/features/home/presentation/widgets/sensor_card.dart';
import 'package:src/features/lamp/data/lamp_repository_impl.dart';
import 'package:src/features/lamp/domain/lamp_repository.dart';
import 'package:src/features/lamp/domain/lamp_state.dart';
import 'package:src/features/lamp/domain/schedule_entry.dart';
import 'package:src/features/profile/presentation/profile_page.dart';
import 'package:src/shared/widgets/app_button.dart';
import 'package:src/shared/widgets/section_title.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LampRepository _lampRepository = LampRepositoryImpl();
  final AuthRepository _authRepository = AuthRepositoryImpl();

  User? _user;
  LampState _lampState = LampState.initial();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final User? currentUser = await _authRepository.getCurrentUser();
    final LampState lampState = await _lampRepository.getLampState();

    if (!mounted) {
      return;
    }

    setState(() {
      _user = currentUser;
      _lampState = lampState;
      _isLoading = false;
    });
  }

  Future<void> _saveLampState(LampState newState) async {
    await _lampRepository.saveLampState(newState);

    if (!mounted) {
      return;
    }

    setState(() {
      _lampState = newState;
    });
  }

  String get _sensorText {
    final double value = _lampState.sensitivity;
    if (value >= 70) {
      return 'Dark';
    }
    if (value >= 40) {
      return 'Normal';
    }
    return 'Bright';
  }

  Future<void> _logOut() async {
    await _authRepository.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  List<ScheduleEntry> get _sortedSchedules {
    final List<ScheduleEntry> items =
        List<ScheduleEntry>.from(_lampState.schedules);
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

  Future<void> _openScheduleEditor({ScheduleEntry? entry}) async {
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
        List<ScheduleEntry>.from(_lampState.schedules);
    final int index =
        schedules.indexWhere((ScheduleEntry item) => item.id == result.id);

    if (index == -1) {
      schedules.add(result);
    } else {
      schedules[index] = result;
    }

    schedules.sort(_compareSchedules);
    await _saveLampState(_lampState.copyWith(schedules: schedules));
  }

  Future<void> _deleteSchedule(String id) async {
    final List<ScheduleEntry> schedules = _lampState.schedules
        .where((ScheduleEntry item) => item.id != id)
        .toList();

    await _saveLampState(_lampState.copyWith(schedules: schedules));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final double width = MediaQuery.sizeOf(context).width;
    final bool isWide = width >= 760;

    final List<Widget> firstColumn = <Widget>[
      LampStatusCard(
        isLampOn: _lampState.isLampOn,
        onToggle: () {
          _saveLampState(
            _lampState.copyWith(isLampOn: !_lampState.isLampOn),
          );
        },
      ),
      const SizedBox(height: 16),
      SensorCard(sensorText: _sensorText),
      const SizedBox(height: 16),
      SensitivityCard(
        value: _lampState.sensitivity,
        onChanged: (double value) {
          _saveLampState(_lampState.copyWith(sensitivity: value));
        },
      ),
    ];

    final List<Widget> secondColumn = <Widget>[
      AutoControlCard(
        isEnabled: _lampState.autoMode,
        onChanged: (bool value) {
          _saveLampState(_lampState.copyWith(autoMode: value));
        },
      ),
      const SizedBox(height: 24),
      SectionTitle(
        title: 'Weekly schedule',
        subtitle: _user == null
            ? 'Add, edit and delete weekly lamp actions here.'
            : 'Manage weekly lamp actions for ${_user!.email}',
      ),
      const SizedBox(height: 12),
      if (_sortedSchedules.isEmpty)
        const Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Text('No schedule yet. Add the first time slot.'),
          ),
        )
      else
        ..._sortedSchedules.map(
          (ScheduleEntry item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ScheduleTile(
              day: item.day,
              time: item.time,
              action: item.action,
              onEdit: () {
                _openScheduleEditor(entry: item);
              },
              onDelete: () {
                _deleteSchedule(item.id);
              },
            ),
          ),
        ),
      const SizedBox(height: 8),
      AppButton(
        title: 'Add schedule',
        icon: Icons.add_rounded,
        onPressed: _openScheduleEditor,
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
              await _loadData();
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
