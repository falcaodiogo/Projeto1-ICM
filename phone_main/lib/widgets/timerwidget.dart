import 'dart:async';
import 'package:flutter/material.dart';

// ignore: use_key_in_widget_constructors
class TimerWidget extends StatefulWidget {
  final VoidCallback onTimerEnd;

  // ignore: use_key_in_widget_constructors, prefer_const_constructors_in_immutables
  TimerWidget({required this.onTimerEnd});

  @override
  // ignore: library_private_types_in_public_api
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  int _timerCountdown = 40;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 19, 35, 44),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 139, 191, 191),
          padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          '00:${_timerCountdown.toString().padLeft(2, '0')}',
          style: const TextStyle(
            color: Color.fromARGB(255, 19, 35, 44),
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if (_timerCountdown < 1) {
          timer.cancel();
          widget.onTimerEnd(); // Notify parent when timer ends
        } else {
          _timerCountdown--;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
