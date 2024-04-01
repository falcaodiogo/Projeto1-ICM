import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
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
  
  late Future<List<double>> user1;
  late Future<List<double>> user2;
  List<double> user1Data = List<double>.empty(growable: true);
  int id1 = 0;
  int id2 = 0;
  List<double> user2Data = List<double>.empty(growable: true);
  bool blurEnabled = false;

  @override
  void initState() {
    super.initState();
    _toggleBlurEveryTwoSeconds();
    _loadUserData();
  }

  Future<void> _loadUserData() async {

    id1 = await widget.isarService.getIdByName("Player 1");
    id2 = await widget.isarService.getIdByName("Player 2");

    List<double> user1List = await widget.isarService.getHeartRateListById(id1);
    List<double> user2List = await widget.isarService.getHeartRateListById(id2);
    
    setState(() {
      user1Data = user1List;
      user2Data = user2List;
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
                        fontFamily: 'Roboto'),
                  ),
                ),
              ),
              const SizedBox(height: kToolbarHeight),
              yellowButton(
                "Start again",
                () {
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
    double score1 = 0.0;
    double score2 = 0.0;
    String name1 = "Player 1";
    String name2 = "Player 2";

    // calculate the average of the list
    for (int i = 0; i < user1Data.length; i++) {
      if (user1Data[i] == 0) {
        continue;
      } else { 
        score1 += user1Data[i];
      }
    }

    for (int i = 0; i < user2Data.length; i++) {
      if (user2Data[i] == 0) {
        continue;
      } else { 
        score2 += user2Data[i];
      }
    }

    score1 = score1 / user1Data.length;
    score2 = score2 / user2Data.length;
    
    return score1 == score2 ? "It's a tie!" : score1 > score2 ? name1 : name2;
  }
}
