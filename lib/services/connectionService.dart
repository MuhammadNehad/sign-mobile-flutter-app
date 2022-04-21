import 'dart:io';

class InternetConnection {
  static Future<bool> checkConn() async {
    try {
      Socket s = await Socket.connect("62.135.109.243", 80,
          timeout: Duration(seconds: 10));
      s.close();
      return true;
    } on SocketException catch (_) {
      print("not connected");
    }
    return false;
  }
}
