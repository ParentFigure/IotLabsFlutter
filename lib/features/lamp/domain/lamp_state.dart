import 'package:src/features/lamp/domain/schedule_entry.dart';

class LampState {
  const LampState({
    required this.isLampOn,
    required this.autoMode,
    required this.sensitivity,
    required this.schedules,
  });

  final bool isLampOn;
  final bool autoMode;
  final double sensitivity;
  final List<ScheduleEntry> schedules;

  LampState copyWith({
    bool? isLampOn,
    bool? autoMode,
    double? sensitivity,
    List<ScheduleEntry>? schedules,
  }) {
    return LampState(
      isLampOn: isLampOn ?? this.isLampOn,
      autoMode: autoMode ?? this.autoMode,
      sensitivity: sensitivity ?? this.sensitivity,
      schedules: schedules ?? this.schedules,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isLampOn': isLampOn,
      'autoMode': autoMode,
      'sensitivity': sensitivity,
      'schedules': schedules
          .map((ScheduleEntry item) => item.toJson())
          .toList(),
    };
  }

  factory LampState.initial() {
    return const LampState(
      isLampOn: true,
      autoMode: true,
      sensitivity: 60,
      schedules: <ScheduleEntry>[
        ScheduleEntry(id: '1', day: 'Mon', time: '06:30', action: 'ON'),
        ScheduleEntry(id: '2', day: 'Mon', time: '08:05', action: 'OFF'),
        ScheduleEntry(id: '3', day: 'Fri', time: '18:40', action: 'ON'),
      ],
    );
  }

  factory LampState.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawSchedules =
        json['schedules'] as List<dynamic>? ?? <dynamic>[];

    return LampState(
      isLampOn: json['isLampOn'] as bool? ?? true,
      autoMode: json['autoMode'] as bool? ?? true,
      sensitivity: (json['sensitivity'] as num?)?.toDouble() ?? 60,
      schedules: rawSchedules
          .whereType<Map<String, dynamic>>()
          .map(ScheduleEntry.fromJson)
          .toList(),
    );
  }
}
