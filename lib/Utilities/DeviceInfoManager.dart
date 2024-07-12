import 'dart:io';

import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';


class DeviceInfoManager {
  static final DeviceInfoManager _instance = DeviceInfoManager._internal();
  String? _deviceId;
  String? _model;
  String? _platform;

  IosDeviceInfo? iosDeviceInfo;
  AndroidDeviceInfo? androidDeviceInfo;

  // Private constructor
  DeviceInfoManager._internal();

  // Public factory
  factory DeviceInfoManager() {
    return _instance;
  }

 // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initDeviceId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) { // import 'dart:io'
    iosDeviceInfo = await deviceInfo.iosInfo;
    String id = iosDeviceInfo!.identifierForVendor!;
    _deviceId = id;
     // unique ID on iOS
  } else if(Platform.isAndroid) {
    androidDeviceInfo = await deviceInfo.androidInfo;
    _deviceId = androidDeviceInfo!.id;
    _model = androidDeviceInfo!.model;
  }
}

String? get deviceId => _deviceId;
String? get model => _model;

// Usage
// Early in your app, initialize the device ID


}