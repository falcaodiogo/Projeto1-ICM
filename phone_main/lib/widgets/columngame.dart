import 'package:flutter/material.dart';
import 'package:phone_main/database/userservice.dart';
import 'package:phone_main/widgets/playerwidget.dart';
import 'package:phone_main/widgets/timerwidget.dart';
import 'package:phone_main/winner.dart';

Widget columnGameState(BuildContext context, IsarService isarService) {
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
          onTimerEnd: goToPage4,
        ),
        const SizedBox(height: 35),
        FutureBuilder<String>(
          future: isarService.getUserName(1),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Placeholder for loading
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return PlayerWidget(
              brightColor: const Color.fromARGB(255, 195, 205, 132),
              darkColor: const Color.fromARGB(255, 169, 177, 117), 
              name: snapshot.data ?? "", // Use snapshot.data to get the result
              heartrate: "", // Replace with actual value if needed
            );
          },
        ),
        const SizedBox(height: 35),
        FutureBuilder<double>(
          future: isarService.getLastHeartRate(1),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Placeholder for loading
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return PlayerWidget(
              brightColor: const Color.fromARGB(255, 204, 154, 99),
              darkColor: const Color.fromARGB(255, 164, 127, 84), 
              name: "", // Replace with actual value if needed
              heartrate: snapshot.data?.toString() ?? "", // Use snapshot.data to get the result
            );
          },
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
