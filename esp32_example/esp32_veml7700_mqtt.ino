#include <WiFi.h>
#include <PubSubClient.h>
#include <Wire.h>
#include <ArduinoJson.h>
#include <Adafruit_VEML7700.h>

constexpr char kWifiSsid[] = "Tank";
constexpr char kWifiPassword[] = "012345678";

constexpr char kMqttHost[] = "broker.emqx.io";
constexpr uint16_t kMqttPort = 1883;
constexpr char kClientId[] = "esp32c5-smartlamp-demo";

constexpr char kTopicLux[] = "smartlamp/demo/telemetry/lux";
constexpr char kTopicState[] = "smartlamp/demo/telemetry/state";
constexpr char kTopicManual[] = "smartlamp/demo/command/manual";
constexpr char kTopicMode[] = "smartlamp/demo/command/mode";
constexpr char kTopicThreshold[] = "smartlamp/demo/command/threshold";

constexpr int kRelayPin = 23;
constexpr int kSdaPin = 5;
constexpr int kSclPin = 4;

WiFiClient wifiClient;
PubSubClient mqttClient(wifiClient);
Adafruit_VEML7700 veml = Adafruit_VEML7700();

bool lampOn = false;
bool autoMode = true;
float luxThreshold = 80;
float currentLux = 0;

void applyLamp(bool value) {
  lampOn = value;
  digitalWrite(kRelayPin, value ? LOW : HIGH);
}

void publishState() {
  StaticJsonDocument<128> doc;
  doc["lampOn"] = lampOn;
  doc["autoMode"] = autoMode;
  doc["threshold"] = luxThreshold;

  char buffer[128];
  serializeJson(doc, buffer);
  mqttClient.publish(kTopicState, buffer, true);
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  String msg;

  for (unsigned int i = 0; i < length; i++) {
    msg += (char)payload[i];
  }

  StaticJsonDocument<128> doc;
  const DeserializationError err = deserializeJson(doc, msg);
  if (err) {
    return;
  }

  const String currentTopic = String(topic);

  if (currentTopic == kTopicManual) {
    const bool value = doc["lampOn"] | false;
    autoMode = false;
    applyLamp(value);
    publishState();
  }

  if (currentTopic == kTopicMode) {
    autoMode = doc["autoMode"] | true;
    publishState();
  }

  if (currentTopic == kTopicThreshold) {
    luxThreshold = doc["threshold"] | 80;
    publishState();
  }
}

void connectWiFi() {
  WiFi.begin(kWifiSsid, kWifiPassword);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
}

void connectMQTT() {
  mqttClient.setServer(kMqttHost, kMqttPort);
  mqttClient.setCallback(mqttCallback);

  while (!mqttClient.connected()) {
    if (mqttClient.connect(kClientId)) {
      mqttClient.subscribe(kTopicManual);
      mqttClient.subscribe(kTopicMode);
      mqttClient.subscribe(kTopicThreshold);
    } else {
      delay(2000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(kRelayPin, OUTPUT);
  digitalWrite(kRelayPin, HIGH);

  Wire.begin(kSdaPin, kSclPin);
  veml.begin();

  connectWiFi();
  connectMQTT();
}

void loop() {
  if (!mqttClient.connected()) {
    connectMQTT();
  }

  mqttClient.loop();
  currentLux = veml.readLux();

  if (autoMode) {
    applyLamp(currentLux < luxThreshold);
  }

  char luxBuffer[16];
  dtostrf(currentLux, 0, 2, luxBuffer);
  mqttClient.publish(kTopicLux, luxBuffer);
  publishState();

  delay(2000);
}
