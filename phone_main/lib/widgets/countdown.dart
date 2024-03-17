import 'dart:async';
import 'package:flutter/material.dart';

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
    'assets/triangle.png'
  ];

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        // If countdown is finished, cancel the timer
        timer.cancel();
      }
    });
  }

  String _getImagePath() {
    return _imagePaths[_countdown - 1];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              _getImagePath(),
              key: ValueKey<int>(_countdown),
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Center(
            child: Text(
              _countdown.toString(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
