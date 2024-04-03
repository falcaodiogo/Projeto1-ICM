import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:phone_main/widgets/yellowbutton.dart';

// ignore: use_key_in_widget_constructors
class EndPage extends StatefulWidget {
  @override
  _EndPageState createState() => _EndPageState();
}

class _EndPageState extends State<EndPage> {
  static const textColor = Color.fromARGB(255, 224, 241, 255);

  bool blurEnabled = false;

  @override
  void initState() {
    super.initState();
    _toggleBlurEveryTwoSeconds();
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
              color: Colors.black.withOpacity(
                  0), 
            ),
          ),
        ),
        _buildAppBar(context),
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30),
              const SizedBox(height: kToolbarHeight),
              Center(
                child: yellowButton("Start again", () => {}, context, 2, ""),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'WearOS app',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
          fontSize: 15,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
