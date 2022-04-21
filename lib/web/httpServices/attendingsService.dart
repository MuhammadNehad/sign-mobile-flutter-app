import 'dart:async';
import 'dart:convert';
import 'package:signingapp/Modals/attendings.dart';

import 'baseService.dart';
import 'package:dio/dio.dart';

class AttendingsServices extends BaseService {
  static Future<bool> add(
      Attendings attending, Map<String, String> authenticatedata) async {
    Response response =
        await (BaseService.makeRequest(BaseService.baseUri + 'attendings',
            mergeDefaultHeader: true,
            extraHeaders: {
              "Authorization":
                  "Bearer ${base64Url.encode(utf8.encode('${authenticatedata["token"]}:${authenticatedata["username"]}:${authenticatedata["password"]}:${authenticatedata["ExpiryDate"]}'))}"
            },
            bodyd: attending));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }
}
