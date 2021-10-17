import 'package:flutter/services.dart';

class BackgroundService {
  MethodChannel platform = MethodChannel('backgroundService');
  void startService() async {
    dynamic value = await platform.invokeMethod("startService");
    print(value);
  }
}
