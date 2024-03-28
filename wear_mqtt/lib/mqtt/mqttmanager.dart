import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_main/mqtt/state/mqtt_appstate.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logger/logger.dart';

// faz listen e dá publish de um topic
class MQTTManager {
  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final String _identifier;
  final String _host;
  final String _topic;

  var logger = Logger( printer: PrettyPrinter());

  MQTTManager(
      {required String host,
      required String topic,
      required String identifier,
      required MQTTAppState state})
      : _identifier = identifier,
        _host = host,
        _topic = topic,
        _currentState = state;

  // not autenticated nedeed
  void initializeMQTTClient() {
    _client = MqttServerClient(_host, _identifier);
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true); // for logging

    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier)
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    if (kDebugMode) {
      logger.d('EXAMPLE::Mosquitto client connecting....');
    }
    _client!.connectionMessage = connMess;
  }

  void connect() async {
    assert(_client != null);
    try {
      if (kDebugMode) {
        logger.d('EXAMPLE::Mosquitto start client connecting....');
      }
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect();
    } on Exception catch (e) {
      if (kDebugMode) {
        logger.d('EXAMPLE::client exception - $e');
      }
      disconnect();
    }
  }

  void disconnect() {

    _currentState.removeDevice(_identifier);
    _removeDeviceInfo();

    Future.delayed(const Duration(seconds: 2), () {
      _client!.disconnect();
      logger.d('EXAMPLE::Disconnected');
    });
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    if (kDebugMode) {
      logger.d('EXAMPLE::Subscription confirmed for topic $topic');
    }
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    logger.d('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      if (kDebugMode) {
        logger.d('EXAMPLE::OnDisconnected callback is solicited, this is correct');
      }
    }
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  /// The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    if (kDebugMode) {
      logger.d('EXAMPLE::Mosquitto client connected....');
    }
    _currentState.addDevice("$_identifier,smartwatch");

    _publishDeviceInfo();

    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message!); // não mexer no !
      
        
      if (_currentState.countDevices() < 2) {
        if (pt.contains("phone") && !_currentState.containsDevice(pt)) {
          _currentState.addDevice(pt);
          _publishDeviceInfo();
        }
      }

      if (pt.contains("remove")) {
        _currentState.removeDevice(pt.split(',')[1]);
        logger.d("Received a remove message and removed device");
      }

      if (kDebugMode) {
        logger.d(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
        logger.d('');
      }
    });
    if (kDebugMode) {
      logger.d(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
    }
  }

  void _publishDeviceInfo() {
    String message = '$_identifier,smartwatch';
    publish(message);
  }

  void _removeDeviceInfo() {
    String message = 'remove,$_identifier';
    publish(message);
  }

}
