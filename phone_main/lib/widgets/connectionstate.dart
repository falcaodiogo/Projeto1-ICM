import 'package:flutter/material.dart';

Widget connectionStateText(String status) {
  return Row(
    children: <Widget>[
      Expanded(
        child: Container(
          color: const Color.fromARGB(255, 255, 238, 0),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color.fromARGB(255, 19, 35, 44)),
          )
        ),
      ),
    ],
  );
}
