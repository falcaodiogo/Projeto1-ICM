import 'package:flutter/material.dart';

Widget playerWidget(BuildContext context, Color brightColor, Color darkColor) {
  return Container(
    decoration: BoxDecoration(
      color: brightColor,
      borderRadius: BorderRadius.circular(20.0),
    ),
    width: MediaQuery.of(context).size.width * 0.85,
    height: MediaQuery.of(context).size.height * 0.27,
    child: Stack(
      children: [
        const Positioned(
          top: 20.0,
          left: 30.0,
          child: Text(
            'Player 1',
            style: TextStyle(
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
              color: darkColor,
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
                            text: '56',
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
}
