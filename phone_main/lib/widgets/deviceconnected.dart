import 'package:flutter/material.dart';

Widget deviceConnected({ required String deviceName, required IconData icon, bool isConnected = false }) {

  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        icon,
        color: isConnected ? Colors.yellow : Colors.grey,
        size: 20,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          '$deviceName ${isConnected ? 'connected' : ' not connected'}',
          style: TextStyle(
            color: isConnected ? Colors.yellow : Colors.grey,
            fontSize: 20,
          ),
        ),
      )
    ],
  );
  
}
