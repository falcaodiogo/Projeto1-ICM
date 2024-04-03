import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }
class MQTTAppState with ChangeNotifier{
  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';
  String _playerName = '';
  bool _gameStarted = false;
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

  void setGameStarted(bool value) {
    _gameStarted = value;
    notifyListeners();
  }

  void setPlayerName(String name) {
    _playerName = name;
    notifyListeners();
  }


  String getPlayerName() {
    return _playerName;
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  bool get getGameStarted => _gameStarted;
  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

  void addDevice(String message) {
    List<String> parts = message.split(',');

    if(_connectedDevices.any((element) => element['deviceId'] == parts[0])) return;
    _connectedDevices.add({'deviceId': parts[0], 'deviceType': parts[1]});
    notifyListeners();
  }


  void removeDevice(String deviceId) {
    if (!_connectedDevices.any((element) => element['deviceId'] == deviceId)) return;
    _connectedDevices.removeWhere((element) => element['deviceId'] == deviceId);
    notifyListeners();
  }

  bool containsDevice(String message) {
    List<String> parts = message.split(',');
    return _connectedDevices.any((element) => element['deviceId'] == parts[0]);
  }

  int countDevices() {
    return _connectedDevices.length;
  }

  int countPhones() {
    return _connectedDevices.where((element) => element['deviceType'] == 'phone').length;
  }

  int countWatches() {
    return _connectedDevices.where((element) => element['deviceType'] == 'smartwatch').length;
  }
}