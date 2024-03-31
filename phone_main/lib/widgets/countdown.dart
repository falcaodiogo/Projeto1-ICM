import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phone_main/database/userservice.dart';
import 'package:phone_main/game.dart';
import 'package:phone_main/mqtt/state/mqttappstate.dart';
import 'package:vibration/vibration.dart';
import 'package:logger/logger.dart';

class CountdownWidget extends StatefulWidget {
  final IsarService isarService;
  final BuildContext context;

  const CountdownWidget({Key? key, required this.isarService, required this.context}) : super(key: key);

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
  final Logger logger = Logger();
  late MQTTAppState currentAppState;

  @override
  void initState() {
    // final MQTTAppState appState = Provider.of<MQTTAppState>(context);
    // currentAppState = appState;
    logger.d("Context FROM COUNTDOWNWIDGET INIT STATE is $context");
    super.initState();
    startCountdown();
    Vibration.vibrate();
  }

  void startCountdown() {
    logger.d("Context FROM COUNTDOWNWIDGET is $context");
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 1) {
          Vibration.vibrate();
          _countdown--;
        } else {
          Vibration.vibrate(pattern: [0, 90, 90, 90, 90, 90, 90, 90]);
          timer.cancel();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => GamePage(isarService: widget.isarService, context: context)));
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
