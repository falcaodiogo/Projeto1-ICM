import 'package:mqtt_client/mqtt_client.dart';
import 'package:phone_main/mqtt/state/mqtt_appstate.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logger/logger.dart';

// faz listen e dá publish de um topic
class MQTTManager {

  final MQTTAppState _currentState;
  MqttServerClient? _client;
  final int _identifier;
  final String _host;
  final String _topic;
  final int _maxDevices = 3;

  var logger = Logger( printer: PrettyPrinter());

  MQTTManager({
    required String host,
    required String topic,
    required int identifier,
    required MQTTAppState state
  }) :
    _identifier = identifier,
    _host = host,
    _topic = topic,
    _currentState = state;

  void initializeMQTTClient() {

    _client = MqttServerClient(_host, _identifier.toString());
    _client!.port = 1883;
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = onDisconnected;
    _client!.secure = false;
    _client!.logging(on: true); // for logging

    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
      .withClientIdentifier(_identifier.toString())
      .withWillTopic('willtopic')
      .withWillMessage('My Will message')
      .startClean() // Non persistent session for testing
      .withWillQos(MqttQos.atLeastOnce);

    logger.i('Client connecting....');
    _client!.connectionMessage = connMess;
  }

  void connect() async {
    assert(_client != null);

    try {

      logger.d('Start client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect();

    } on Exception catch (e) {
 
      logger.e('Client exception - $e');
      disconnect();

    }
  }

  void disconnect() {

    _currentState.removeDevice(_identifier.toString());
    _removeDeviceInfo();

    Future.delayed(const Duration(seconds: 2), () {

      _client!.disconnect();
      logger.d('Disconnected');
    });

  }

  // Publish a message to a topic
  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    logger.i('Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {

    logger.i('OnDisconnected client callback - Client disconnection');

    if (_client!.connectionStatus!.returnCode == MqttConnectReturnCode.noneSpecified) {
      logger.d('OnDisconnected callback is solicited, this is correct');
    }

    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);

  }

  /// The successful connect callback
  void onConnected() {

    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    logger.d('Client connected...');

    _currentState.setPlayerName("Player $_identifier");
    _currentState.addDevice("$_identifier,smartwatch");
    _publishDeviceInfo();

    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {

      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);
      
      // Add a device to the list of connected devices
      if (_currentState.countDevices() < _maxDevices) {

        if ((pt.contains("phone") || pt.contains("smartwatch")) && !(_currentState.containsDevice(pt))) {

          _currentState.addDevice(pt);
          _publishDeviceInfo();
          logger.i("Received a message and added device");
        }

      }

      // Remove a device from the list of connected devices
      if (pt.contains("remove")) {

        _currentState.removeDevice(pt.split(',')[1].toString());
        logger.i("Received a remove message and removed device");

      }

      logger.i('Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');

    });
    logger.d('EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  // Publish the device info like its type, identifier and name
  void _publishDeviceInfo() {

    String message = '$_identifier,smartwatch,${_currentState.getPlayerName}';
    publish(message);

  } 

  // Inform the other devices that this device is disconnecting
  void _removeDeviceInfo() {

    String message = 'remove,$_identifier';
    publish(message);

  }
}
