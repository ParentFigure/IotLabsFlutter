part of 'lamp_controller.dart';

extension LampControllerUpdates on LampController {
  void _handleMessage(String rawMessage) {
    try {
      final Map<String, dynamic>? decoded =
          jsonDecode(rawMessage) as Map<String, dynamic>?;
      if (decoded == null) {
        return;
      }
      final String topic = decoded['topic'] as String? ?? '';
      final String payload = decoded['payload'] as String? ?? '';
      if (topic.endsWith('/telemetry/lux')) {
        _updateLux(payload);
        return;
      }
      if (topic.endsWith('/telemetry/state')) {
        _updateTelemetry(payload);
      }
    } catch (error) {
      _setMessage('MQTT parse error: $error');
    }
  }

  void _updateLux(String payload) {
    _updateState(
      _state.copyWith(sensorLux: double.tryParse(payload) ?? _state.sensorLux),
    );
  }

  void _updateTelemetry(String payload) {
    final Map<String, dynamic>? data =
        jsonDecode(payload) as Map<String, dynamic>?;
    if (data == null) {
      return;
    }
    _updateState(
      _state.copyWith(
        isLampOn: data['lampOn'] as bool? ?? _state.isLampOn,
        autoMode: data['autoMode'] as bool? ?? _state.autoMode,
        sensitivity:
            (data['threshold'] as num?)?.toDouble() ?? _state.sensitivity,
      ),
    );
  }
}
