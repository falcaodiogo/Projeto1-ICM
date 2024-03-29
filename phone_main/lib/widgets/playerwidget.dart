import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:phone_main/mqtt/state/mqttappstate.dart';
import 'package:provider/provider.dart';

class PlayerWidget extends StatefulWidget {
  final Color brightColor;
  final Color darkColor;
  final String name;

  const PlayerWidget(
      {super.key,
      required this.brightColor,
      required this.darkColor,
      required this.name});

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<MQTTAppState>(builder: (context, currentAppState, child) {
      logger.i('PlayerWidget: Context $context');
      logger.i('PlayerWidget: currentAppState $currentAppState');
      logger.i('heart beat value ${currentAppState.getReceivedText}');
      return Container(
        decoration: BoxDecoration(
          color: widget.brightColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.27,
        child: Stack(
          children: [
            Positioned(
              top: 20.0,
              left: 30.0,
              child: Text(
                widget.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Positioned(
              top: 67.0,
              left: 27.0,
              right: 27.0,
              bottom: 27.0,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.darkColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text:'0.0',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 55.0,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              TextSpan(
                                text: ' bpm',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
