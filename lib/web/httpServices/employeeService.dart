import 'dart:async';
import 'dart:convert';
import 'package:signingapp/Modals/EmpsLocsView.dart';
import 'package:signingapp/Modals/UserLogin.dart';
import 'package:signingapp/dbHelper/sqliteHelper.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'baseService.dart';
import 'package:dio/dio.dart';

import 'package:signingapp/globals.dart' as globals;

class EmpsServices extends BaseService {
  static Future<bool> checkexists(String phone) async {
    Response response = await Dio().get(
        Uri.parse(BaseService.baseUri + 'Emplyees/GetEmplyeesByPhone/' + phone)
            .toString());
    if (response.statusCode == 200 || response.statusCode == 401) {
      Map<String, dynamic> responseMap = json.decode(response.data);
      print(responseMap);
      return responseMap['message'];
    } else {
      throw ('unknown Error Occured');
    }
  }

  static Future<List<Emps_Locs_View>> getEmplyeesViewService() async {
    Response response = await (BaseService.makeRequest(
        BaseService.baseUri + 'EmpsLocView',
        method: "GET"));

    if (response.statusCode == 200) {
      var responsedecode = utf8.decode(response.data);
      var responseMap = json.decode(responsedecode);
      for (var e in responseMap) {
        Emps_Locs_View emlv = Emps_Locs_View();
        emlv
          ..LOCID = e['locid']
          ..empemail = e['empemail']
          ..empCode = e['empCode']
          ..empId = e['empId']
          ..empName = e['empName']
          ..empPhone = e['empPhone']
          ..LocLatitude = e['locLatitude']
          ..locLngtude = e['locLngtude']
          ..ELocaddress = e['eLocaddress']
          ..totalHours = e['totalHours']
          ..entering = e['entering'];

        print(responseMap);
      }
      List<Emps_Locs_View> emp = [];
      return emp;
    } else {
      throw ('unknown Error Occured');
    }
  }

  static Future<Emps_Locs_View> getEmplyeesViewServiceBP(String phone) async {
    Response response = await (BaseService.makeRequest(
        BaseService.baseUri + 'EmpsLocView/' + phone,
        method: "GET"));

    var responseMap = response.data;
    Emps_Locs_View emplv;
    if (response.statusCode == 200) {
      for (var e in responseMap) {
        globals.shared.setString("phone", phone);
        emplv = Emps_Locs_View.fromMap(e);
        await db.deleteEmpsLocsView(emplv);

        await db.insertEmps_Locs_View(emplv);
      }

      db.close();
      return emplv ?? null;
    } else {
      throw ('unknown Error Occured');
    }
  }

  static Future<Emps_Locs_View> getEmplyeesViewServiceBCode(
      String code, Map<String, String> authenticatedata) async {
    Response response = await (BaseService.makeRequest(
        BaseService.baseUri + 'EmpsLocView/GetByCode/$code',
        mergeDefaultHeader: true,
        extraHeaders: {
          "Authorization":
              "Bearer ${base64Url.encode(utf8.encode('${authenticatedata["token"]}:${authenticatedata["username"]}:${authenticatedata["password"]}:${authenticatedata["ExpiryDate"]}'))}"
        },
        method: "GET"));
    // dbHelper db = dbHelper();

    var sharedPrefs = await SharedPreferences.getInstance();
    if (response.statusCode == 200) {
      var responseMap = response.data;
      Emps_Locs_View emplv;
      for (var e in responseMap) {
        sharedPrefs.setString("myCode", code);

        emplv = Emps_Locs_View.fromMap(e);
        sharedPrefs.setDouble("lat", emplv.LocLatitude ?? 0.0);
        sharedPrefs.setDouble("lng", emplv.locLngtude ?? 0.0);
        if (!sharedPrefs.containsKey("lastTimeInTheZone....") ||
            sharedPrefs.getString("lastTimeInTheZone....") == null) {
          sharedPrefs.setBool("entering", false);
        } else {
          sharedPrefs.setBool("entering", emplv.entering);
        }

        sharedPrefs.setInt("empId", emplv.empId);
        sharedPrefs.setInt("locId", emplv.LOCID ?? 0);
        sharedPrefs.setString("dateTime", emplv.dateTime.toString());
      }

      return emplv ?? null;
    } else {
      return null;
    }
  }

  static Future<bool> login(UserLogin userLogin) async {
    Response response = await (BaseService.makeRequest(
        BaseService.baseUri + 'Authenticate',
        bodyd: FormData.fromMap(
            {'code': userLogin.code, 'password': userLogin.password}),
        method: "POST",
        fromForm: true));
    var responseMap = response.data;
    globals.shared.setString("usertoken", responseMap["token"]["value"]);
    globals.shared.setString("password", responseMap["user"]["password"]);
    globals.shared.setString(
        "ExpiryDate", responseMap["token"]["expiryDate"].replaceAll(':', '/'));
    if ((response.statusCode == 200 || response.statusCode == 204) &&
        responseMap["user"]["loggedIn"] != 1) {
      if (await setOnline(
          responseMap["user"]["id"], true, responseMap["user"]["empCode"], {
        "Authorization":
            "Bearer ${base64Url.encode(utf8.encode('${responseMap["token"]["value"]}:${responseMap["user"]["empCode"]}:${responseMap["user"]["password"]}:${responseMap["token"]["expiryDate"]}'))}"
      })) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> setOnline(int id, bool isOnline, String empCode,
      Map<String, String> authenticatedata) async {
    Response response = await (BaseService.makeRequest(
        BaseService.baseUri + 'Authenticate/setOnline/$id',
        bodyd: FormData.fromMap({'id': id, 'empCode': empCode}),
        mergeDefaultHeader: true,
        extraHeaders: authenticatedata,
        method: "PUT"));
    if (response.statusCode == 200 || response.statusCode == 204) {
      globals.shared.setInt("isOnline", isOnline ? 1 : 0);
      return true;
    } else {
      return false;
    }
  }

  // static Future<Box<Emplyee>> getEmplyeesService() async {
  //   Response response = await (BaseService.makeRequest(
  //       BaseService.baseUri + 'Emplyees',
  //       method: "GET"));
  //   var responseMap = response.data;
  //   for (var e in responseMap) {
  //     var i = e;
  //     String id = i['id'].toString();
  //     String phoneNum = i['phone'];
  //     String email = i['email'];
  //     String name = i['name'];
  //     String locationId = i['locationKey'].toString();
  //     if (!Hive.box<Emplyee>("employees").isOpen) {
  //       Hive.openBox<Emplyee>("employees");
  //     }
  //     await Hive.box<Emplyee>("employees").put(
  //         id,
  //         Emplyee(
  //             id: id,
  //             name: name,
  //             phone: phoneNum,
  //             email: email,
  //             locationKey: int.parse(locationId)));
  //     print(responseMap);
  //   }
  //   if (response.statusCode == 200) {
  //     Box<Emplyee> emp = Boxes.getEmployees();
  //     return emp;
  //   } else {
  //     throw ('unknown Error Occured');
  //   }
  // }
}
