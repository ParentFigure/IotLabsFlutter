import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:src/features/lamp/domain/mqtt_service.dart';

class MqttServiceImpl implements MqttService {
  final StreamController<String> _messages =
      StreamController<String>.broadcast();
  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>?
      _updatesSubscription;
  MqttTopics? _topics;

  @override
  Stream<String> get messages => _messages.stream;

  @override
  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  @override
  Future<void> connect({
    required String server,
    required int port,
    required MqttTopics topics,
  }) async {
    await disconnect();
    _topics = topics;

    final String clientId =
        'flutter_smart_lamp_${DateTime.now().millisecondsSinceEpoch}';

    final MqttServerClient client = MqttServerClient(server, clientId)
      ..port = port
      ..keepAlivePeriod = 20
      ..autoReconnect = true
      ..resubscribeOnAutoReconnect = true
      ..logging(on: false);

    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.onAutoReconnect = _onAutoReconnect;
    client.onAutoReconnected = _onAutoReconnected;
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    _client = client;

    try {
      await client.connect();
    } catch (error) {
      client.disconnect();
      _client = null;
      rethrow;
    }

    final status = client.connectionStatus;
    if (status?.state != MqttConnectionState.connected) {
      final String reason = status?.returnCode.toString() ?? 'unknown error';
      client.disconnect();
      _client = null;
      throw Exception('MQTT connect failed: $reason');
    }

    client.subscribe(topics.luxTopic, MqttQos.atMostOnce);
    client.subscribe(topics.stateTopic, MqttQos.atMostOnce);

    await _updatesSubscription?.cancel();
    _updatesSubscription = client.updates?.listen(_handleUpdates);
  }

  void _handleUpdates(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final MqttReceivedMessage<MqttMessage> message in messages) {
      final MqttPublishMessage publishMessage =
          message.payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
        publishMessage.payload.message,
      );

      _messages.add(
        jsonEncode(
          <String, String>{
            'topic': message.topic,
            'payload': payload,
          },
        ),
      );
    }
  }

  void _onConnected() {
    _messages.add(
      jsonEncode(
        <String, String>{
          'type': 'system',
          'value': 'connected',
        },
      ),
    );
  }

  void _onDisconnected() {
    _messages.add(
      jsonEncode(
        <String, String>{
          'type': 'system',
          'value': 'disconnected',
        },
      ),
    );
  }

  void _onAutoReconnect() {
    _messages.add(
      jsonEncode(
        <String, String>{
          'type': 'system',
          'value': 'reconnecting',
        },
      ),
    );
  }

  void _onAutoReconnected() {
    final MqttServerClient? client = _client;
    final MqttTopics? topics = _topics;

    if (client != null && topics != null) {
      client.subscribe(topics.luxTopic, MqttQos.atMostOnce);
      client.subscribe(topics.stateTopic, MqttQos.atMostOnce);
    }

    _messages.add(
      jsonEncode(
        <String, String>{
          'type': 'system',
          'value': 'reconnected',
        },
      ),
    );
  }

  @override
  Future<void> publish({required String topic, required String payload}) async {
    final MqttServerClient? client = _client;
    if (client == null || !isConnected) {
      return;
    }

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder()
      ..addString(payload);

    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  @override
  Future<void> disconnect() async {
    await _updatesSubscription?.cancel();
    _updatesSubscription = null;
    _client?.disconnect();
    _client = null;
  }
}
