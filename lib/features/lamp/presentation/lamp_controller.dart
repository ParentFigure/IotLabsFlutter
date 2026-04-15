import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:src/features/lamp/domain/lamp_repository.dart';
import 'package:src/features/lamp/domain/lamp_state.dart';
import 'package:src/features/lamp/domain/mqtt_service.dart';
import 'package:src/features/lamp/domain/schedule_entry.dart';
import 'package:src/shared/connectivity/network_controller.dart';

class LampController extends ChangeNotifier {
  LampController({
    required LampRepository lampRepository,
    required MqttService mqttService,
    required NetworkController networkController,
  }) : _lampRepository = lampRepository,
       _mqttService = mqttService,
       _networkController = networkController;

  final LampRepository _lampRepository;
  final MqttService _mqttService;
  final NetworkController _networkController;

  LampState _state = LampState.initial();
  bool _isLoading = true;
  bool _isMqttConnecting = false;
  String? _message;
  StreamSubscription<String>? _mqttSubscription;
  bool _initialized = false;

  LampState get state => _state;
  bool get isLoading => _isLoading;
  bool get isMqttConnecting => _isMqttConnecting;
  bool get isBrokerConnected => _mqttService.isConnected;
  String? get message => _message;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    _state = await _lampRepository.syncLampState();
    _isLoading = false;
    _message = _networkController.isOnline
        ? 'Remote sync finished. Latest state is cached locally.'
        : 'Offline mode: cached state restored from local storage.';
    notifyListeners();
    await connectMqtt();
  }

  Future<void> connectMqtt() async {
    if (!_networkController.isOnline) {
      _message = 'No Internet connection. MQTT is unavailable.';
      notifyListeners();
      return;
    }

    _isMqttConnecting = true;
    notifyListeners();

    try {
      await _mqttService.connect(
        server: _state.broker,
        port: _state.port,
        topics: MqttTopics(
          luxTopic: _state.topic('telemetry/lux'),
          stateTopic: _state.topic('telemetry/state'),
          manualTopic: _state.topic('command/manual'),
          modeTopic: _state.topic('command/mode'),
          thresholdTopic: _state.topic('command/threshold'),
          scheduleTopic: _state.topic('command/schedule'),
        ),
      );
      await _mqttSubscription?.cancel();
      _mqttSubscription = _mqttService.messages.listen(_handleMessage);
    } catch (error) {
      _message = 'MQTT connection failed: $error';
    }

    _isMqttConnecting = false;
    notifyListeners();
  }

  void _handleMessage(String rawMessage) {
    try {
      final Object? decoded = jsonDecode(rawMessage);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      final String topic = decoded['topic'] as String? ?? '';
      final String payload = decoded['payload'] as String? ?? '';
      if (topic.endsWith('/telemetry/lux')) {
        final double lux = double.tryParse(payload) ?? _state.sensorLux;
        _updateState(_state.copyWith(sensorLux: lux));
        return;
      }

      if (topic.endsWith('/telemetry/state')) {
        final Object? stateJson = jsonDecode(payload);
        if (stateJson is! Map<String, dynamic>) {
          return;
        }

        _updateState(
          _state.copyWith(
            isLampOn: stateJson['lampOn'] as bool? ?? _state.isLampOn,
            autoMode: stateJson['autoMode'] as bool? ?? _state.autoMode,
            sensitivity:
                (stateJson['threshold'] as num?)?.toDouble() ??
                _state.sensitivity,
          ),
        );
      }
    } catch (error) {
      _message = 'MQTT parse error: $error';
      notifyListeners();
    }
  }

  Future<void> setManualLamp(bool value) async {
    await _updateState(_state.copyWith(isLampOn: value));
    await _mqttService.publish(
      topic: _state.topic('command/manual'),
      payload: jsonEncode(<String, dynamic>{'lampOn': value}),
    );
  }

  Future<void> setAutoMode(bool value) async {
    await _updateState(_state.copyWith(autoMode: value));
    await _mqttService.publish(
      topic: _state.topic('command/mode'),
      payload: jsonEncode(<String, dynamic>{'autoMode': value}),
    );
  }

  Future<void> setSensitivity(double value) async {
    await _updateState(_state.copyWith(sensitivity: value));
    await _mqttService.publish(
      topic: _state.topic('command/threshold'),
      payload: jsonEncode(<String, dynamic>{'threshold': value.round()}),
    );
  }

  Future<void> saveSchedules(List<ScheduleEntry> schedules) async {
    await _updateState(_state.copyWith(schedules: schedules));
    await _mqttService.publish(
      topic: _state.topic('command/schedule'),
      payload: jsonEncode(
        schedules.map((ScheduleEntry item) => item.toJson()).toList(),
      ),
    );
  }

  Future<void> updateBroker({
    required String broker,
    required int port,
    required String topicPrefix,
  }) async {
    await _updateState(
      _state.copyWith(broker: broker, port: port, topicPrefix: topicPrefix),
    );
    await connectMqtt();
  }

  Future<void> _updateState(LampState newState) async {
    _state = newState;
    await _lampRepository.saveLampState(newState);
    notifyListeners();
  }

  Future<void> disconnect() => _mqttService.disconnect();

  void clearMessage() {
    _message = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _mqttSubscription?.cancel();
    _mqttService.disconnect();
    super.dispose();
  }
}
