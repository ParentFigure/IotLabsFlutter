import 'package:flutter/material.dart';
import 'package:src/features/home/presentation/helpers/schedule_utils.dart';
import 'package:src/features/lamp/domain/schedule_entry.dart';

Future<ScheduleEntry?> openScheduleEditor(
  BuildContext context, {
  ScheduleEntry? entry,
}) {
  TimeOfDay selectedTime = entry == null
      ? const TimeOfDay(hour: 6, minute: 30)
      : parseScheduleTime(entry.time);
  String selectedAction = entry?.action ?? 'ON';
  String selectedDay = entry?.day ?? ScheduleEntry.days.first;

  return showDialog<ScheduleEntry>(
    context: context,
    builder: (_) => StatefulBuilder(
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
                onChanged: (String? value) =>
                    setModalState(() => selectedDay = value ?? selectedDay),
                decoration: const InputDecoration(labelText: 'Day'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Time'),
                subtitle: Text(selectedTime.format(context)),
                trailing: const Icon(Icons.access_time_rounded),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setModalState(() => selectedTime = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedAction,
                items: const <DropdownMenuItem<String>>[
                  DropdownMenuItem(value: 'ON', child: Text('ON')),
                  DropdownMenuItem(value: 'OFF', child: Text('OFF')),
                ],
                onChanged: (String? value) =>
                    setModalState(() => selectedAction = value ?? 'ON'),
                decoration: const InputDecoration(labelText: 'Action'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                ScheduleEntry(
                  id:
                      entry?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  day: selectedDay,
                  time: formatScheduleTime(selectedTime),
                  action: selectedAction,
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  );
}
