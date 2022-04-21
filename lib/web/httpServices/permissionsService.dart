import 'dart:convert';

import 'baseService.dart';
import 'package:dio/dio.dart';

class Permission extends BaseService {
  static Future<dynamic> checkPermissions(
      Map<String, String> authenticatedata) async {
    Response response = await (BaseService.makeRequest(
        BaseService.baseUri +
            'Permissions/getByName?permsNames[0]=EmpsLocation view',
        extraHeaders: {
          "Authorization":
              "Bearer ${base64Url.encode(utf8.encode('${authenticatedata["token"]}:${authenticatedata["username"]}:${authenticatedata["password"]}:${authenticatedata["ExpiryDate"]}'))}"
        },
        method: "GET"));
    var responseMap = response.data;
    return responseMap;
  }
}
