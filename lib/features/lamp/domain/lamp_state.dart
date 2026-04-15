import 'package:src/features/lamp/domain/schedule_entry.dart';

class LampState {
  const LampState({
    required this.isLampOn,
    required this.autoMode,
    required this.sensitivity,
    required this.sensorLux,
    required this.broker,
    required this.port,
    required this.topicPrefix,
    required this.schedules,
  });

  final bool isLampOn;
  final bool autoMode;
  final double sensitivity;
  final double sensorLux;
  final String broker;
  final int port;
  final String topicPrefix;
  final List<ScheduleEntry> schedules;

  LampState copyWith({
    bool? isLampOn,
    bool? autoMode,
    double? sensitivity,
    double? sensorLux,
    String? broker,
    int? port,
    String? topicPrefix,
    List<ScheduleEntry>? schedules,
  }) {
    return LampState(
      isLampOn: isLampOn ?? this.isLampOn,
      autoMode: autoMode ?? this.autoMode,
      sensitivity: sensitivity ?? this.sensitivity,
      sensorLux: sensorLux ?? this.sensorLux,
      broker: broker ?? this.broker,
      port: port ?? this.port,
      topicPrefix: topicPrefix ?? this.topicPrefix,
      schedules: schedules ?? this.schedules,
    );
  }

  String topic(String suffix) => '$topicPrefix/$suffix';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isLampOn': isLampOn,
      'autoMode': autoMode,
      'sensitivity': sensitivity,
      'sensorLux': sensorLux,
      'broker': broker,
      'port': port,
      'topicPrefix': topicPrefix,
      'schedules': schedules
          .map((ScheduleEntry item) => item.toJson())
          .toList(),
    };
  }

  factory LampState.initial() {
    return const LampState(
      isLampOn: false,
      autoMode: true,
      sensitivity: 80,
      sensorLux: 0,
      broker: 'broker.emqx.io',
      port: 1883,
      topicPrefix: 'smartlamp/demo',
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
      isLampOn: json['isLampOn'] as bool? ?? false,
      autoMode: json['autoMode'] as bool? ?? true,
      sensitivity: (json['sensitivity'] as num?)?.toDouble() ?? 80,
      sensorLux: (json['sensorLux'] as num?)?.toDouble() ?? 0,
      broker: json['broker'] as String? ?? 'broker.emqx.io',
      port: json['port'] as int? ?? 1883,
      topicPrefix: json['topicPrefix'] as String? ?? 'smartlamp/demo',
      schedules: rawSchedules
          .whereType<Map<String, dynamic>>()
          .map(ScheduleEntry.fromJson)
          .toList(),
    );
  }
}
