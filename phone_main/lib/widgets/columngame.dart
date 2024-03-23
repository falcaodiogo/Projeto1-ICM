import 'package:flutter/material.dart';
import 'package:phone_main/widgets/playerwidget.dart';
import 'package:phone_main/widgets/timerwidget.dart';
import 'package:phone_main/widgets/yellowbutton.dart';


Widget columnGameState(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: <Widget>[
        const SizedBox(height: 20),
        TimerWidget(),
        const SizedBox(height: 35),
        playerWidget(context, const Color.fromARGB(255, 195, 205, 132),
            const Color.fromARGB(255, 169, 177, 117)),
        const SizedBox(height: 35),
        playerWidget(context, const Color.fromARGB(255, 204, 154, 99),
            const Color.fromARGB(255, 164, 127, 84)),
        const SizedBox(height: 35),
        yellowButton("End", () {}),
      ],
    ),
  );
}
