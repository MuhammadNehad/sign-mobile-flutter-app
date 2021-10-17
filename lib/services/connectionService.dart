import 'dart:io';

class InternetConnection {
  static Future<bool> checkConn() async {
    try {
      final resultGoogle = await InternetAddress.lookup("www.google.com");
      if (resultGoogle.isNotEmpty && resultGoogle[0].rawAddress.isNotEmpty) {
        final result = await InternetAddress.lookup("192.168.1.4");
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
        return false;
      }
    } on SocketException catch (_) {
      print("not connected");
    }
    return false;
  }
}