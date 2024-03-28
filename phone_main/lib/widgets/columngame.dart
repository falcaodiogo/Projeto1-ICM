import 'package:flutter/material.dart';
import 'package:phone_main/database/isar_service.dart';
import 'package:phone_main/database/user.dart';
import 'package:phone_main/widgets/playerwidget.dart';
import 'package:phone_main/widgets/timerwidget.dart';
import 'package:phone_main/winner.dart';

Widget columnGameState(BuildContext context, IsarService isarService) {
  Future<List<User>> getAllUsers() async {
    return await isarService.getAllUser();
  }

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
        FutureBuilder<List<User>>(
          future: getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final users = snapshot.data!;
              String? firstUserName = users[users.length - 1].name;
              double? heartRate = users[users.length - 1].heartRate;
              return PlayerWidget(
                brightColor: const Color.fromARGB(255, 195, 205, 132),
                darkColor: const Color.fromARGB(255, 169, 177, 117),
                name: firstUserName!,
                heartrate: heartRate.toString(),
              );
            }
          },
        ),
        const SizedBox(height: 35),
        const PlayerWidget(
          brightColor: Color.fromARGB(255, 204, 154, 99),
          darkColor: Color.fromARGB(255, 164, 127, 84),
          name: '',
          heartrate: '',
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
