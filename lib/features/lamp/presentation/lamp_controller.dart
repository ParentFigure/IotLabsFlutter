import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:src/features/home/presentation/helpers/schedule_utils.dart';
import 'package:src/features/lamp/domain/lamp_repository.dart';
import 'package:src/features/lamp/domain/lamp_state.dart';
import 'package:src/features/lamp/domain/mqtt_service.dart';
import 'package:src/features/lamp/domain/schedule_entry.dart';
import 'package:src/shared/connectivity/network_controller.dart';

part 'lamp_controller_actions.dart';
part 'lamp_controller_updates.dart';

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
  StreamSubscription<String>? _mqttSubscription;
  bool _initialized = false;
  bool _isLoading = true;
  bool _isMqttConnecting = false;
  String? _message;

  LampState get state => _state;
  bool get isLoading => _isLoading;
  bool get isMqttConnecting => _isMqttConnecting;
  bool get isBrokerConnected => _mqttService.isConnected;
  String? get message => _message;

  void _emit() => notifyListeners();

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
      _setMessage('No Internet connection. MQTT is unavailable.');
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
      _setMessage('MQTT connection failed: $error');
    }

    _isMqttConnecting = false;
    notifyListeners();
  }

  Future<void> _updateState(LampState newState) async {
    _state = newState;
    await _lampRepository.saveLampState(newState);
    _emit();
  }

  void clearMessage() => _setMessage(null);

  void _setMessage(String? value) {
    _message = value;
    _emit();
  }

  @override
  void dispose() {
    _mqttSubscription?.cancel();
    _mqttService.disconnect();
    super.dispose();
  }
}
