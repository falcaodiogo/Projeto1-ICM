
import 'package:flutter/cupertino.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }

class MQTTAppState with ChangeNotifier{

  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';

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

  // Count the number of devices that are connected
  int countDevices() {
    return _connectedDevices.length;
  }

  // Count the number of devices which are phones that are connected
  int countPhones() {
    return _connectedDevices.where((element) => element['deviceType'] == 'phone').length;
  }

  // Count the number of devices which are smartwatches that are connected
  int countWatches() {
    return _connectedDevices.where((element) => element['deviceType'] == 'watch').length;
  }
}