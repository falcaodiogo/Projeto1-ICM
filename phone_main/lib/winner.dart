import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phone_main/database/user.dart';
import 'package:phone_main/database/userservice.dart';
import 'package:phone_main/widgets/yellowbutton.dart';

// ignore: use_key_in_widget_constructors
class EndPage extends StatefulWidget {
  
  final IsarService isarService;

  // ignore: use_key_in_widget_constructors
  const EndPage({required this.isarService});

  @override
  State<StatefulWidget> createState() {
    return _EndPageState();
  }
}

class _EndPageState extends State<EndPage> {

  static const textColor = Color.fromARGB(255, 224, 241, 255);
  static const accentColor = Color.fromARGB(255, 255, 238, 0);

  List<User> users = List<User>.empty(growable: true);
  bool blurEnabled = false;

  @override
  void initState() {

    super.initState();
    _toggleBlurEveryTwoSeconds();
    _loadUserData();

  }

  Future<void> _loadUserData() async {

    List<User> usersList = await widget.isarService.getAllUser();

    setState(() {
      users = usersList;
    });

  }

  void _toggleBlurEveryTwoSeconds() {

    Timer.periodic(const Duration(seconds: 1), (timer) {

      setState(() {
        blurEnabled = !blurEnabled;
      });

    });

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/background.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 1000),
          opacity: blurEnabled ? 1.0 : 0.0,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Colors.black.withOpacity(0),
            ),
          ),
        ),
        _buildAppBar(context),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 320,
                height: 200,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    _gameResult(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      fontFamily: 'Roboto'
                    ),
                  ),
                ),
              ),
              const SizedBox(height: kToolbarHeight),
              yellowButton(
                "Start again", () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'Phone app',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
          fontSize: 25,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  String _gameResult() {

    List<double> scores = List<double>.empty(growable: true);
    Map<double, String> scoreMap = <double, String>{};

    // Calculate the average heartrate for each user
    for (User user in users) {

      double score = ((user.heartrate!.reduce((a, b) => a + b)) / user.heartrate!.length).roundToDouble();
      scores.add(score);
      scoreMap[score] = user.name!;

    }

    // Order the scores in ascending order
    scores.sort();

    return scores.first == scores.last ?
      "Its a tie with a score of ${scores.last} for both players" :
      "${scoreMap[scores.last]} with a score of ${scores.last}";
  }
}
