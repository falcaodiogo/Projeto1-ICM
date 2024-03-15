import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phone_main/mqtt/state/mqtt_appstate.dart';
import 'package:phone_main/mqtt/mqttmanager.dart';
import 'package:uuid/uuid.dart';
import 'package:workout/workout.dart';

class MQTTView extends StatefulWidget {
  const MQTTView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  final workout = Workout();
  late MQTTAppState currentAppState;
  late MQTTManager manager;
  static const backgroundColor = Color.fromARGB(255, 19, 35, 44);
  static const accentColor = Color.fromARGB(255, 255, 238, 0);
  static const secondAccentColor = Color.fromARGB(255, 231, 224, 126);
  static const thirdAccentColor = Color.fromARGB(255, 80, 78, 54);
  static const textColor = Color.fromARGB(255, 224, 241, 255);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _hostTextController.dispose();
    _messageTextController.dispose();
    _topicTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildAppBar(context),
          _buildConnectionStateText(
              _prepareStateMessageFrom(currentAppState.getAppConnectionState)),
          _buildEditableColumn(),
          _buildScrollableTextWith(currentAppState.getHistoryText),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'WearOS app',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.w500, color: textColor, fontSize: 15),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
    );
  }

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: accentColor,
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(color: backgroundColor),
              )),
        ),
      ],
    );
  }

  Widget _buildEditableColumn() {
    // são os valores que segui do tutorial de mqtt 
    _hostTextController.text = 'test.mosquitto.org';
    _topicTextController.text = 'flutter/amp/cool';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          _buildPublishMessageRow(),
          const SizedBox(height: 10),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState)
        ],
      ),
    );
  }

  Widget _buildPublishMessageRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: _buildTextFieldWith(_messageTextController, 'Enter a message',
              currentAppState.getAppConnectionState),
        ),
        _buildSendButtonFrom(currentAppState.getAppConnectionState)
      ],
    );
  }

  Widget _buildTextFieldWith(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if (controller == _messageTextController &&
        state == MQTTAppConnectionState.connected) {
      shouldEnable = true;
    } else if ((controller == _hostTextController &&
            state == MQTTAppConnectionState.disconnected) ||
        (controller == _topicTextController &&
            state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: 400,
        height: 200,
        child: SingleChildScrollView(
          child: Text(text),
        ),
      ),
    );
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    bool isConnected = state == MQTTAppConnectionState.connected;

    return Row(
      children: <Widget>[
        Expanded(
          child: Switch(
            value: isConnected,
            activeColor: thirdAccentColor,
            activeTrackColor: accentColor,
            inactiveThumbColor: secondAccentColor,
            inactiveTrackColor: thirdAccentColor,
            onChanged: (bool value) {
              if (value) {
                _configureAndConnect();
              } else {
                _disconnect();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSendButtonFrom(MQTTAppConnectionState state) {
    return ElevatedButton(
      onPressed: state == MQTTAppConnectionState.connected
          ? () {
              _publishMessage(_messageTextController.text);
            }
          : null,
      child: const Text('Send'), //
    );
  }

  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  void _configureAndConnect() {
    String osPrefix = Platform.isAndroid ? 'Android_' : 'iOS_';
    String uniqueClientId = osPrefix + const Uuid().v4();

    manager = MQTTManager(
        host: _hostTextController.text,
        topic: _topicTextController.text,
        identifier: uniqueClientId,
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
    _startHeartbeat();
  }

  void _startHeartbeat() {
    double heartRate = 0;

    const features = [
    WorkoutFeature.heartRate,
  ];

    workout.start(exerciseType: ExerciseType.walking, features: features);

    workout.stream.listen((event) {
      setState(() {
        heartRate = event.value;
      });
    });

    const Duration heartbeatInterval = Duration(seconds: 4);
    Timer.periodic(heartbeatInterval, (timer) {
      String heartbeatMessage =
          'Heartbeat: ${DateTime.now()}, Heart Rate: $heartRate';
      manager.publish(heartbeatMessage);
    });
  }

  void _disconnect() {
    manager.disconnect();
  }

  void _publishMessage(String text) {
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    final String message = '$osPrefix says: $text';
    manager.publish(message);
    _messageTextController.clear();
  }
}
