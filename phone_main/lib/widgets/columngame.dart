import 'package:flutter/material.dart';
import 'package:phone_main/database/user.dart';
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
        StreamBuilder<List<User>>(
          stream: isarService.listenUser(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return Column(
              children: snapshot.data!.map((user) {
                return Column(
                  children: [
                    PlayerWidget(
                      brightColor: const Color.fromARGB(255, 195, 205, 132),
                      darkColor: const Color.fromARGB(255, 169, 177, 117),
                      name: user.name!,
                      heartrate: user.heartrate!.isNotEmpty ? user.heartrate!.last.toString() : "", // assuming heartrate is a list
                    ),
                    const SizedBox(height: 35),
                  ],
                );
              }).toList(),
            );
          },
        ),
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
