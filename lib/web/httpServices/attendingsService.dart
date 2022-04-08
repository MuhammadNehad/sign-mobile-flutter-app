import 'dart:async';
import 'dart:convert';

import 'package:signingapp/Modals/attendings.dart';

import 'baseService.dart';
import 'package:dio/dio.dart';

class AttendingsServices extends BaseService {
  // static Future<bool> get() async {
  //   http.Response response = await http.post(Uri.parse(
  //       BaseService.baseUri + 'attendings/' + phone));
  //   if (response.statusCode == 200 || response.statusCode == 401) {
  //     Map<String, dynamic> responseMap = json.decode(response.body);
  //     print(responseMap);
  //     return responseMap['message'];
  //   } else {
  //     throw ('unknown Error Occured');
  //   }
  // }

  static Future<bool> add(Attendings attending) async {
    Response response = await (BaseService.makeRequest(
        BaseService.baseUri + 'attendings',
        bodyd: attending));
    var s = response.data;
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Map<String, dynamic> responseMap = json.decode(response.body);
      // print(responseMap);
      return true;
    } else {
      return false;
    }
  }
}
