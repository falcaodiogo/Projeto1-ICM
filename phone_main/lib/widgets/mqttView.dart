import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phone_main/widgets/appbar.dart';
import 'package:phone_main/widgets/countdown.dart';
import 'package:phone_main/widgets/yellowbutton.dart';
import 'package:provider/provider.dart';
import 'package:phone_main/mqtt/state/MQTTAppState.dart';
import 'package:phone_main/mqtt/MQTTManager.dart';
import 'package:uuid/uuid.dart';

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
          appBar(context),
          if (currentAppState.getAppConnectionState !=
              MQTTAppConnectionState.connected)
            connectionStateText(_prepareStateMessageFrom(
                currentAppState.getAppConnectionState)),
          mainColumn(),
          // _buildScrollableTextWith(currentAppState.getHistoryText),
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
          const SizedBox(height: 200),
          if (currentAppState.getAppConnectionState ==
              MQTTAppConnectionState.disconnected)
            const Column(
              children: [
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
              ],
            ),
          const SizedBox(height: 30),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState)
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
          yellowButton("Start", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Animate(child: CountdownWidget())),
            );
          }
          ),
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

  void _configureAndConnect() {
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
  
  // Widget _buildScrollableTextWith(String text) {
  //   return Padding(
  //     padding: const EdgeInsets.all(20.0),
  //     child: SizedBox(
  //       width: 400,
  //       height: 200,
  //       child: SingleChildScrollView(
  //         child: Text(text),
  //       ),
  //     ),
  //   );
  // }
}
