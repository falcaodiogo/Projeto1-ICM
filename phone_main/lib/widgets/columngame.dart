import 'package:flutter/material.dart';
import 'package:phone_main/widgets/playerwidget.dart';
import 'package:phone_main/widgets/timerwidget.dart';
import 'package:phone_main/winner.dart';

Widget columnGameState(BuildContext context) {
  void goToPage4() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EndPage()),
    );
  }

  return SingleChildScrollView(
    child: Column(
      children: <Widget>[
        const SizedBox(height: 20),
        TimerWidget(
          onTimerEnd: goToPage4, // Pass callback function
        ),
        const SizedBox(height: 35),
        const PlayerWidget(
          brightColor: Color.fromARGB(255, 195, 205, 132),
          darkColor: Color.fromARGB(255, 169, 177, 117),
        ),
        const SizedBox(height: 35),
        const PlayerWidget(
          brightColor: Color.fromARGB(255, 204, 154, 99),
          darkColor: Color.fromARGB(255, 164, 127, 84),
        ),
        const SizedBox(height: 35),
        // go to first page
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "End",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        )
      ],
    ),
  );
}
