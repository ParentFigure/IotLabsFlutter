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
    final MqttServerClient client = _buildClient(server, port);
    _client = client;
    try {
      await client.connect();
      _ensureConnected(client);
      _subscribe(client, topics);
      await _updatesSubscription?.cancel();
      _updatesSubscription = client.updates?.listen(_handleUpdates);
    } catch (_) {
      await disconnect();
      rethrow;
    }
  }

  MqttServerClient _buildClient(String server, int port) {
    final String clientId =
        'flutter_smart_lamp_${DateTime.now().millisecondsSinceEpoch}';
    final MqttServerClient client = MqttServerClient(server, clientId);
    final MqttConnectMessage message = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.port = port;
    client.keepAlivePeriod = 20;
    client.autoReconnect = true;
    client.resubscribeOnAutoReconnect = true;
    client.logging(on: false);
    client.onConnected = () => _pushSystem('connected');
    client.onDisconnected = () => _pushSystem('disconnected');
    client.onAutoReconnect = () => _pushSystem('reconnecting');
    client.onAutoReconnected = _onAutoReconnected;
    client.connectionMessage = message;
    return client;
  }

  void _ensureConnected(MqttServerClient client) {
    final status = client.connectionStatus;
    if (status?.state == MqttConnectionState.connected) {
      return;
    }
    throw Exception(
      'MQTT connect failed: ${status?.returnCode ?? 'unknown error'}',
    );
  }

  void _subscribe(MqttServerClient client, MqttTopics topics) {
    client.subscribe(topics.luxTopic, MqttQos.atMostOnce);
    client.subscribe(topics.stateTopic, MqttQos.atMostOnce);
  }

  void _handleUpdates(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final MqttReceivedMessage<MqttMessage> message in messages) {
      final MqttPublishMessage publishMessage =
          message.payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
        publishMessage.payload.message,
      );
      _messages.add(
        jsonEncode(<String, String>{
          'topic': message.topic,
          'payload': payload,
        }),
      );
    }
  }

  void _onAutoReconnected() {
    final MqttServerClient? client = _client;
    final MqttTopics? topics = _topics;
    if (client != null && topics != null) {
      _subscribe(client, topics);
    }
    _pushSystem('reconnected');
  }

  void _pushSystem(String value) {
    _messages.add(
      jsonEncode(<String, String>{'type': 'system', 'value': value}),
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
