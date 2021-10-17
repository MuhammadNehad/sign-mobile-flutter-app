import 'dart:ui';

import 'package:flutter/services.dart';

import 'backTask.dart';

class RunDartInBackground {
  static const MethodChannel _channel = const MethodChannel('main_channel');

  static Future<void> initialize() async {
    final CallbackHandle callback =
        PluginUtilities.getCallbackHandle(callbackDispatcher);
    var raw = callback.toRawHandle();
    await _channel.invokeMethod('initializeService', <dynamic>[raw]);
  }

  static void test(void Function(String s) callback) async {
    var raw = PluginUtilities.getCallbackHandle(callback).toRawHandle();
    await _channel.invokeMethod('run', [raw]);
  }
}
