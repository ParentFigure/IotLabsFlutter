import 'package:flutter/material.dart';
import 'package:src/features/lamp/domain/schedule_entry.dart';

List<ScheduleEntry> sortSchedules(List<ScheduleEntry> schedules) {
  final List<ScheduleEntry> items = List<ScheduleEntry>.from(schedules);
  items.sort(compareSchedules);
  return items;
}

int compareSchedules(ScheduleEntry a, ScheduleEntry b) {
  final int dayDiff = dayIndex(a.day).compareTo(dayIndex(b.day));
  return dayDiff == 0 ? a.time.compareTo(b.time) : dayDiff;
}

int dayIndex(String day) => ScheduleEntry.days.indexOf(day);

TimeOfDay parseScheduleTime(String value) {
  final List<String> parts = value.split(':');
  return TimeOfDay(
    hour: int.tryParse(parts.first) ?? 0,
    minute: int.tryParse(parts.last) ?? 0,
  );
}

String formatScheduleTime(TimeOfDay value) {
  final String hour = value.hour.toString().padLeft(2, '0');
  final String minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
