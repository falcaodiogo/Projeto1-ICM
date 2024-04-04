import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier{

  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  
  String _receivedText = '';
  String _historyText = '';
  String _playerName = '';

  Logger logger = Logger();

  final List<Map<String, dynamic>> _connectedDevices = [];

  void setReceivedText(String text) {

    _receivedText = text;
    _historyText = '$_historyText\n$_receivedText';
    notifyListeners();

  }

  void setAppConnectionState(MQTTAppConnectionState state) {

    _appConnectionState = state;
    notifyListeners();

  }

  void setPlayerName(String name) {

    _playerName = name;
    notifyListeners();

  }

  String get getPlayerName => _playerName;
  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

  // Add a device to the list of connected devices
  void addDevice(String message) {

    List<String> parts = message.split(',');

    if(_connectedDevices.any((element) => element['deviceId'] == parts[0])) return;

    _connectedDevices.add({'deviceId': parts[0], 'deviceType': parts[1]});
    notifyListeners();

  }

  // Remove a device from the list of connected devices
  void removeDevice(String deviceId) {

    if (!_connectedDevices.any((element) => element['deviceId'] == deviceId)) return;

    _connectedDevices.removeWhere((element) => element['deviceId'] == deviceId);
    notifyListeners();

  }

  // Check if a given device is already connected
  bool containsDevice(String message) {

    List<String> parts = message.split(',');
    return _connectedDevices.any((element) => element['deviceId'] == parts[0]);

  }

  // Count the number of connected devices
  int countDevices() {
    return _connectedDevices.length;
  }

  // Count the number of connected devices which are phones
  int countPhones() {
    return _connectedDevices.where((element) => element['deviceType'] == 'phone').length;
  }

  // Count the number of connected devices which are smartwatches
  int countWatches() {
    return _connectedDevices.where((element) => element['deviceType'] == 'smartwatch').length;
  }

}