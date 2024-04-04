import 'package:flutter/material.dart';
import 'package:phone_main/database/userservice.dart';
import 'package:phone_main/mqtt/state/mqttappstate.dart';
import 'package:phone_main/widgets/appbar.dart';
import 'package:phone_main/widgets/columngame.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

// ignore: use_key_in_widget_constructors
class GamePage extends StatelessWidget {
  
  final Logger logger = Logger();
  final IsarService isarService;
  final BuildContext context;

  GamePage({super.key, required this.isarService, required this.context});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MQTTAppState(),
      child: Container(
        color: const Color.fromARGB(255, 19, 35, 44),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              appBar(context),
              columnGameState(context, isarService),
            ],
          ),
        ),
      ),
    );
  }
}
