import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phone_main/database/isar_service.dart';
import 'package:phone_main/database/user.dart';
import 'package:phone_main/widgets/appbar.dart';
import 'package:phone_main/widgets/countdown.dart';
import 'package:phone_main/widgets/deviceconnected.dart';
import 'package:phone_main/widgets/yellowbutton.dart';
import 'package:provider/provider.dart';
import 'package:phone_main/mqtt/state/mqttappstate.dart';
import 'package:phone_main/mqtt/mqttmanager.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

class MQTTView extends StatefulWidget {
  const MQTTView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MQTTViewState();
  }
}

class _MQTTViewState extends State<MQTTView> {
  IsarService isarService = IsarService();
  final TextEditingController _hostTextController = TextEditingController();
  final TextEditingController _messageTextController = TextEditingController();
  final TextEditingController _topicTextController = TextEditingController();
  late MQTTAppState currentAppState;
  late MQTTManager manager;
  static const backgroundColor = Color.fromARGB(255, 19, 35, 44);
  static const accentColor = Color.fromARGB(255, 255, 238, 0);
  static const secondAccentColor = Color.fromARGB(255, 231, 224, 126);
  static const thirdAccentColor = Color.fromARGB(255, 80, 78, 54);
  static const textColor = Color.fromARGB(255, 224, 241, 255);
  static final Logger logger = Logger();
  final int _maxDevices = 2;

  @override
  void initState() {
    super.initState();
    User user1 = User(1, 'Player test 1', 0.0);
    isarService.saveUser(user1);
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
    logger.d("Context FROM MQTTVIEW is $context");
    final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    currentAppState = appState;
    // messages = 'Heartbeat: $heartRate, deviceCount: ${currentAppState.countDevices()}';
    double heartRate = currentAppState.getReceivedText.contains('Heartbeat: ')
        ? double.parse(currentAppState.getReceivedText
            .split('Heartbeat: ')[1]
            .split(', deviceCount:')[0])
        : 0;

    isarService.updateUser(User(1, 'Player test 1', heartRate));
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          appBar(context),
          if (currentAppState.getAppConnectionState !=
              MQTTAppConnectionState.connected)
            connectionStateText(_prepareStateMessageFrom(
                currentAppState.getAppConnectionState)),
          mainColumn(),
        ],
      ),
    );
  }

  Widget connectionStateText(String status) {
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

  Widget mainColumn() {
    _hostTextController.text = 'test.mosquitto.org';
    _topicTextController.text = 'flutter/amp/cool';
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          //image
          const SizedBox(height: 70),
          const Image(
            image: AssetImage('assets/image.png'),
            height: 200,
          ),
          const SizedBox(height: 50),

          if (currentAppState.getAppConnectionState ==
              MQTTAppConnectionState.disconnected)
            const Column(
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Connection is non\n-existent!",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: textColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),

          if (currentAppState.getAppConnectionState ==
              MQTTAppConnectionState.connecting)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingAnimationWidget.inkDrop(
                  color: Colors.white,
                  size: 50,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Connecting...",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: textColor),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),

          const SizedBox(height: 50),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState),
          // buildanother(currentAppState),
        ],
      ),
    );
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    bool isConnected = state == MQTTAppConnectionState.connected;
    String connectionStatus = isConnected ? "Connected" : "Connect";

    return Column(
      children: [
        if (isConnected)

          if (currentAppState.countDevices() < _maxDevices)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              deviceConnected(deviceName: "phone", icon: Icons.phone_android_rounded, isConnected: currentAppState.countDevices() > 0),
              deviceConnected(deviceName: "smartwatch", icon: Icons.watch_rounded, isConnected: currentAppState.countWatches() > 0)
            ]
          ),
          
          if (currentAppState.countDevices() == _maxDevices)
            yellowButton("Start", () {
              manager.startGame();
              Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Animate(child: CountdownWidget())),
            );
            }),

        if (isConnected) const SizedBox(height: 90),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              connectionStatus,
              style: const TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 14),
            Switch(
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
          ],
        ),
      ],
    );
  }

  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
      case MQTTAppConnectionState.connected:
        return '';
    }
  }

  void _configureAndConnect() async {
    String osPrefix = Platform.isAndroid ? 'Android_' : 'iOS_';
    String uniqueClientId = osPrefix + const Uuid().v4(); // Generate UUID v4

    manager = MQTTManager(
        host: _hostTextController.text,
        topic: _topicTextController.text,
        identifier: uniqueClientId,
        state: currentAppState);
    manager.initializeMQTTClient();
    manager.connect();
  }

  void _disconnect() {
    manager.disconnect();
  }
}
