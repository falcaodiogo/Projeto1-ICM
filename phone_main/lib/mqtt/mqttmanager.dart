import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:phone_main/database/user.dart';
import 'package:phone_main/database/userservice.dart';
import 'package:phone_main/mqtt/state/mqttappstate.dart';
import 'package:logger/logger.dart';

class MQTTManager {
  // Private instance of client
  final MQTTAppState _currentState;
  final IsarService _isarService;
  MqttServerClient? _client;
  final int _identifier;
  final String _host;
  final String _topic;
  final int _maxDevices = 3;
  List<User> users = [];

  var logger = Logger(printer: PrettyPrinter());

  // Constructor
  // ignore: sort_constructors_first
  MQTTManager(
      {required IsarService isarService,
      required String host,
      required String topic,
      required int identifier,
      required MQTTAppState state})
      : _isarService = isarService,
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
    _client!.logging(on: true);

    /// Add the successful connection callback
    _client!.onConnected = onConnected;
    _client!.onSubscribed = onSubscribed;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(_identifier.toString())
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    logger.d('EXAMPLE::Mosquitto client connecting....');
    _client!.connectionMessage = connMess;
  }

  // Connect to the host
  // ignore: avoid_void_async
  void connect() async {
    assert(_client != null);
    try {
      logger.d('EXAMPLE::Mosquitto start client connecting....');
      _currentState.setAppConnectionState(MQTTAppConnectionState.connecting);
      await _client!.connect();
    } on Exception catch (e) {
      logger.d('EXAMPLE::client exception - $e');
      disconnect();
    }
  }

  void disconnect() {
    _currentState.removeDevice(_identifier.toString());
    _removeDeviceInfo();

    Future.delayed(const Duration(seconds: 2), () {
      logger.d('Disconnected');
      _client!.disconnect();
    });
  }

  void publish(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(_topic, MqttQos.exactlyOnce, builder.payload!);
  }

  /// The subscribed callback
  void onSubscribed(String topic) {
    logger.d('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    logger.d('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client!.connectionStatus!.returnCode ==
        MqttConnectReturnCode.noneSpecified) {
      logger
          .d('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    }
    _currentState.setAppConnectionState(MQTTAppConnectionState.disconnected);
  }

  // The successful connect callback
  void onConnected() {
    _currentState.setAppConnectionState(MQTTAppConnectionState.connected);
    logger.d('EXAMPLE::Mosquitto client connected....');
    _currentState.addDevice("$_identifier,phone");

    _publishDeviceInfo();

    _client!.subscribe(_topic, MqttQos.atLeastOnce);
    _client!.updates!
        .listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      // ignore: avoid_as
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;

      // final MqttPublishMessage recMess = c![0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message!);

      if (_currentState.countDevices() < _maxDevices &&
          pt.contains("smartwatch") &&
          !(_currentState.containsDevice(pt))) {

        _currentState.addDevice(pt);
        _publishDeviceInfo();

        int id = int.parse(pt.split(",")[0]);
        String playerName = pt.split(",")[2];
        User user = User(id, playerName, []);

        if (!users.contains(user)) {
          users.add(user);
          _isarService.saveUser(user);
        }
      }

      if (pt.contains("remove")) {
        _currentState.removeDevice(pt.split(",")[1]);
        logger.d("Received a remove message and removed device");
      }

      if (pt.contains("Heart Rate")) {
        double heartRate =
            double.parse(pt.split('Heart Rate: ')[1].split(', identifier')[0]);

        int userId = int.parse(pt.split(', identifier: ')[1]);
        logger.e("Heart Rate: $heartRate, identifier: $userId");

        for (User user in users) {
          if (user.id == userId) {
            user.heartrate?.add(heartRate);
            _isarService.addHeartRate(user, heartRate);
            break;
          }
        }

      }

      _currentState.setReceivedText(pt);

      logger.d(
          'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      logger.d('');
    });
    logger.d(
        'EXAMPLE::OnConnected client callback - Client connection was sucessful');
  }

  // Publish info about the device like if it is a phone or a smartwatch
  void _publishDeviceInfo() {
    String message = '$_identifier,phone';
    publish(message);
  }

  void _removeDeviceInfo() {
    String message = 'remove,$_identifier';
    publish(message);
  }

  void startGame() {
    String message = 'start';
    publish(message);
  }

  void endGame() {
    String message = 'end';
    publish(message);
  }
}
