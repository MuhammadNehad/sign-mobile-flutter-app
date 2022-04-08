import 'dart:convert';

import 'baseService.dart';
import 'package:dio/dio.dart';

class Permission extends BaseService {
  static Future<dynamic> checkPermissions() async {
    Response response = await (BaseService.makeRequest(
        BaseService.baseUri +
            'Permissions/getByName?permsNames[0]=EmpsLocation view',
        method: "GET"));
    var responseMap = response.data;
    return responseMap;
  }
}
