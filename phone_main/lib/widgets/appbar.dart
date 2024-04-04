import 'package:flutter/material.dart';

Widget appBar(BuildContext context) {
  return AppBar(
    title: const Text(
      'Phone app',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 224, 241, 255)),
    ),
    centerTitle: true,
    backgroundColor: const Color.fromARGB(255, 19, 35, 44),
  );
}
