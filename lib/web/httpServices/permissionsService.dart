import 'dart:convert';

import 'baseService.dart';
import 'package:http/http.dart' as http;

class Permission extends BaseService {
  static Future<dynamic> checkPermissions() async {
    http.Response response = await (BaseService.makeRequest(
        BaseService.baseUri +
            'Permissions/getByName?permsNames[0]=EmpsLocation view',
        method: "GET"));
    var responseMap = json.decode(utf8.decode(response.bodyBytes));
    return responseMap;
  }
}
