import 'package:flutter/material.dart';
import 'package:phone_main/widgets/appbar.dart';
import 'package:phone_main/widgets/columngame.dart';

// ignore: use_key_in_widget_constructors
class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 19, 35, 44),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            appBar(context),
            columnGameState(context),
          ],
        ),
      ),
    );
  }
}