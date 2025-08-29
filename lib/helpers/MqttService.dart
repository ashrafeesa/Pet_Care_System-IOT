import 'dart:async';
import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// --- Connection states for easy identification ---
enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING,
}

enum MqttSubscriptionState { IDLE, SUBSCRIBED }

/// --- MQTT Client Wrapper ---
class MQTTClientWrapper {
  late MqttServerClient client;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  final String broker;
  final int port;
  final String clientId;
  final String username;
  final String password;

  MQTTClientWrapper({
    required this.broker,
    this.port = 8883,
    required this.clientId,
    required this.username,
    required this.password,
  }) {
    _setupMqttClient();
  }

  /// Prepare and connect client
  Future<void> prepareMqttClient() async {
    await _connectClient();
  }

  /// Setup MQTT Client
  void _setupMqttClient() {
    client = MqttServerClient.withPort(broker, clientId, port);
    client.logging(on: true);

    // TLS / SSL enabled
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;

    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  /// Connect to broker
  Future<void> _connectClient() async {
    try {
      print('🔄 Client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .authenticateAs(username, password)
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

      client.connectionMessage = connMessage;
      await client.connect(username, password);
    } on Exception catch (e) {
      print('⚠️ Client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('✅ Client connected');
    } else {
      print(
        '❌ ERROR client connection failed - disconnecting, status is ${client.connectionStatus}',
      );
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  /// Subscribe to topic
  void subscribeToTopic(String topicName) {
    if (connectionState != MqttCurrentConnectionState.CONNECTED) {
      print("⚠️ Cannot subscribe, client not connected!");
      return;
    }

    print('📩 Subscribing to topic: $topicName');
    client.subscribe(topicName, MqttQos.atMostOnce);

    // Listen for incoming messages
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String message = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      print('📨 New message on topic <${c[0].topic}>: $message');
    });
  }

  // Publish message
  void publishMessage(String topic, String message) {
    if (connectionState != MqttCurrentConnectionState.CONNECTED) {
      print("⚠️ Cannot publish, client not connected!");
      return;
    }

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);

    print('📤 Publishing "$message" to topic $topic');
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// --- Callbacks ---
  void _onSubscribed(String topic) {
    print('✅ Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onDisconnected() {
    print('🔌 Disconnected from broker');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print('🔗 Connected to broker successfully');
  }
}
