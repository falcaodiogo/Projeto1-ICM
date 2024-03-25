import 'package:flutter/material.dart';
import 'package:phone_main/endpage.dart';
import 'package:phone_main/heartbeats.dart';

Widget yellowButton(
    String text, Function onPressed, BuildContext context, int first) {
  return ElevatedButton(
    onPressed: () {
      onPressed();
      switch (first) {
        case 0:
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => GamePage()));
          break;
        case 1:
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => EndPage()));
          break;
        default:
          Navigator.of(context).popUntil((route) => route.isFirst);
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.yellow,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
      ),
    ),
  );
}
