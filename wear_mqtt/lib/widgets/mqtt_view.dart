import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phone_main/widgets/deviceconnected.dart';
import 'package:phone_main/widgets/yellowbutton.dart';
import 'package:provider/provider.dart';
import 'package:phone_main/mqtt/state/mqtt_appstate.dart';
import 'package:phone_main/mqtt/mqttmanager.dart';
import 'package:logger/logger.dart';
import 'package:workout/workout.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  final Logger logger = Logger(printer: PrettyPrinter());

  final int _maxDevices = 3;
  final int uniqueClientId = Random().nextInt(1000) + Random().nextInt(1001);

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
            _prepareStateMessageFrom(currentAppState.getAppConnectionState)
          ),
          _buildEditableColumn(currentAppState.getAppConnectionState, context),
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
          fontWeight: FontWeight.w500, 
          color: textColor, 
          fontSize: 15
        ),
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
            )
          ),
        ),
      ],
    );
  }

  Widget _buildEditableColumn(
      MQTTAppConnectionState state, BuildContext context) {

    _hostTextController.text = 'test.mosquitto.org';
    _topicTextController.text = 'flutter/amp/cool';

    bool isConnected = state == MQTTAppConnectionState.connected;

    return Column(
      children: <Widget>[
        const SizedBox(
          height: 20,
        ),

        if (isConnected && currentAppState.countDevices() < _maxDevices)

          Column(mainAxisAlignment: MainAxisAlignment.center, children: [

            deviceConnected(
              deviceName: "phone",
              icon: Icons.phone_android_rounded,
              isConnected: currentAppState.countPhones() > 0
            ),

            deviceConnected(
              deviceName: "smartwatch 1",
              icon: Icons.watch_rounded,
              isConnected: currentAppState.countWatches() == 1
            ),

            deviceConnected(
              deviceName: "smartwatch 2",
              icon: Icons.watch_rounded,
              isConnected: currentAppState.countWatches() > 1
            ),

          ]),

        if (isConnected && currentAppState.countDevices() == _maxDevices)

          yellowButton("Start", _startHeartbeat, context, 0, currentAppState.getPlayerName),

        if (state == MQTTAppConnectionState.connecting)

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingAnimationWidget.inkDrop(
                size: 25,
                color: Colors.white,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Connecting...",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

        if (!isConnected)

          const Center(
            child: Text("Connection is non-\nexistent!",
              textAlign: TextAlign.center,
              style:
                TextStyle(color: textColor, fontWeight: FontWeight.bold)
            ),
          ),

        const SizedBox(
          height: 10,
        ),
        _buildConnecteButtonFrom(currentAppState.getAppConnectionState)
      ],
    );
  }

  Widget _buildScrollableTextWith(String text) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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
              value ? _configureAndConnect() : _disconnect();
            },
          ),
        ),
      ],
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

    manager = MQTTManager(
      host: _hostTextController.text,
      topic: _topicTextController.text,
      identifier: uniqueClientId,
      state: currentAppState
    );

    manager.initializeMQTTClient();
    manager.connect();
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

      String heartbeatMessage = 'Heartbeat: ${DateTime.now()}, Heart Rate: $heartRate, identifier: $uniqueClientId';
      manager.publish(heartbeatMessage);

    });
  }

  void _disconnect() {
    manager.disconnect();
  }
}
