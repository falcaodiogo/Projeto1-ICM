import 'package:flutter/material.dart';
import 'package:phone_main/mqtt/state/mqttappstate.dart';
import 'package:phone_main/widgets/playerwidget.dart';
import 'package:phone_main/widgets/timerwidget.dart';
import 'package:phone_main/widgets/yellowbutton.dart';
import 'package:logger/logger.dart';


Widget columnGameState(BuildContext context) {

  // final mqtttAppState = Provider.of<MQTTAppState>(context);
  final Logger logger = Logger();
  logger.d("Context FROM COLUMNGAME is $context");
  final mqtttAppState = MQTTAppState();

  return SingleChildScrollView(
    child: Column(
      children: <Widget>[
        const SizedBox(height: 20),
        TimerWidget(),
        const SizedBox(height: 35),
        playerWidget(context, const Color.fromARGB(255, 195, 205, 132),
            const Color.fromARGB(255, 169, 177, 117), mqtttAppState.getReceivedText),
        const SizedBox(height: 35),
        playerWidget(context, const Color.fromARGB(255, 204, 154, 99),
            const Color.fromARGB(255, 164, 127, 84), mqtttAppState.getReceivedText),
        const SizedBox(height: 35),
        yellowButton("End", () {}),
      ],
    ),
  );
}
