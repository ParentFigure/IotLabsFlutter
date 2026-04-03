class ScheduleEntry {
  const ScheduleEntry({
    required this.id,
    required this.day,
    required this.time,
    required this.action,
  });

  final String id;
  final String day;
  final String time;
  final String action;

  static const List<String> days = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  ScheduleEntry copyWith({
    String? id,
    String? day,
    String? time,
    String? action,
  }) {
    return ScheduleEntry(
      id: id ?? this.id,
      day: day ?? this.day,
      time: time ?? this.time,
      action: action ?? this.action,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'day': day,
      'time': time,
      'action': action,
    };
  }

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    final String rawDay = json['day'] as String? ?? 'Mon';

    return ScheduleEntry(
      id: json['id'] as String? ?? '',
      day: days.contains(rawDay) ? rawDay : 'Mon',
      time: json['time'] as String? ?? '00:00',
      action: json['action'] as String? ?? 'ON',
    );
  }
}
