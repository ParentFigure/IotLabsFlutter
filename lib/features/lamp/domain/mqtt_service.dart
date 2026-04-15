abstract class MqttService {
  Stream<String> get messages;
  bool get isConnected;

  Future<void> connect({
    required String server,
    required int port,
    required MqttTopics topics,
  });

  Future<void> publish({required String topic, required String payload});

  Future<void> disconnect();
}

class MqttTopics {
  const MqttTopics({
    required this.luxTopic,
    required this.stateTopic,
    required this.manualTopic,
    required this.modeTopic,
    required this.thresholdTopic,
    required this.scheduleTopic,
  });

  final String luxTopic;
  final String stateTopic;
  final String manualTopic;
  final String modeTopic;
  final String thresholdTopic;
  final String scheduleTopic;
}
