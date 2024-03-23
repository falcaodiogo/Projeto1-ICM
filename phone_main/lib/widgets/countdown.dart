import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phone_main/game.dart';
import 'package:vibration/vibration.dart';

// ignore: use_key_in_widget_constructors
class CountdownWidget extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  int _countdown = 3;
  final List<String> _imagePaths = [
    'assets/coli.png',
    'assets/squarish.png',
    'assets/triangle.png',
  ];

  @override
  void initState() {
    super.initState();
    startCountdown();
    Vibration.vibrate();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 1) {
          Vibration.vibrate();
          _countdown--;
        } else {
          Vibration.vibrate(pattern: [0, 90, 90, 90, 90, 90, 90, 90]);
          timer.cancel();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => GamePage()));
        }
      });
    });
  }

  String get imagePath => _imagePaths[_countdown - 1];

  String _getImagePath() {
    return _imagePaths[_countdown - 1];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        color: const Color.fromARGB(255, 19, 35, 44),
        child: Stack(
          children: [
            Positioned(
              top: 90,
              left: 8,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.vertical,
                    child: child,
                  );
                },
                child: Image.asset(_getImagePath(),
                    key: ValueKey<int>(_countdown),
                    fit: BoxFit.cover,
                    width: 400),
              ),
            ),
            Center(
              child: Text(
                _countdown.toString(),
                style: const TextStyle(
                  fontSize: 128,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
