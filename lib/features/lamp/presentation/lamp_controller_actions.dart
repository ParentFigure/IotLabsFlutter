part of 'lamp_controller.dart';

extension LampControllerActions on LampController {
  Future<void> setManualLamp(bool value) {
    return _publishState(
      _state.copyWith(isLampOn: value),
      'command/manual',
      <String, dynamic>{'lampOn': value},
    );
  }

  Future<void> setAutoMode(bool value) {
    return _publishState(
      _state.copyWith(autoMode: value),
      'command/mode',
      <String, dynamic>{'autoMode': value},
    );
  }

  Future<void> setSensitivity(double value) {
    return _publishState(
      _state.copyWith(sensitivity: value),
      'command/threshold',
      <String, dynamic>{'threshold': value.round()},
    );
  }

  Future<void> saveSchedules(List<ScheduleEntry> schedules) {
    return _publishState(
      _state.copyWith(schedules: schedules),
      'command/schedule',
      schedules.map((ScheduleEntry item) => item.toJson()).toList(),
    );
  }

  Future<void> upsertSchedule(ScheduleEntry entry) async {
    final List<ScheduleEntry> schedules = List<ScheduleEntry>.from(
      _state.schedules,
    );
    final int index = schedules.indexWhere(
      (ScheduleEntry item) => item.id == entry.id,
    );
    if (index == -1) {
      schedules.add(entry);
    } else {
      schedules[index] = entry;
    }
    await saveSchedules(sortSchedules(schedules));
  }

  Future<void> deleteSchedule(String id) async {
    await saveSchedules(
      _state.schedules.where((ScheduleEntry item) => item.id != id).toList(),
    );
  }

  Future<void> _publishState(
    LampState nextState,
    String topic,
    Object payload,
  ) async {
    await _updateState(nextState);
    await _mqttService.publish(
      topic: _state.topic(topic),
      payload: jsonEncode(payload),
    );
  }
}
