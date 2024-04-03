import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phone_main/widgets/yellowbutton.dart';

// ignore: use_key_in_widget_constructors
class GamePage extends StatelessWidget {
  static const backgroundColor = Color.fromARGB(255, 19, 35, 44);
  static const accentColor = Color.fromARGB(255, 255, 238, 0);
  static const secondAccentColor = Color.fromARGB(255, 231, 224, 126);
  static const thirdAccentColor = Color.fromARGB(255, 80, 78, 54);
  static const textColor = Color.fromARGB(255, 224, 241, 255);
  final String playerName;

  // constructor for GamePage
  GamePage(this.playerName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildAppBar(context),
            const Text(
              'Measuring heartbeats...',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  decoration: TextDecoration.none),
            ),
            const SizedBox(
              height: 15,
            ),
            SvgPicture.asset(
              'assets/heart.svg',
              colorFilter: const ColorFilter.mode(accentColor, BlendMode.srcIn),
              semanticsLabel: 'A red up arrow',
              width: 45,
            ),
            Center(
              child: Text(
                playerName,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: accentColor,
                    fontSize: 15,
                    fontFamily: 'Roboto',
                    decoration: TextDecoration.none),
              )
            ),
            const SizedBox(
              height: 15,
            ),
            yellowButton("Stop", () => {}, context, 1, playerName),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'WearOS app',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.w500, color: textColor, fontSize: 15),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
    );
  }
}
