import 'dart:io';

class InternetConnection {
  static Future<bool> checkConn() async {
    try {
      final resultGoogle = await InternetAddress.lookup("www.google.com");
      if (resultGoogle.isNotEmpty && resultGoogle[0].rawAddress.isNotEmpty) {
        final result = await InternetAddress.lookup("62.135.109.243");
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
