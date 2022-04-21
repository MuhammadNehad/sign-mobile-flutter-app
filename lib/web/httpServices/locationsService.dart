import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signingapp/Modals/locations.dart';
import 'package:signingapp/dbHelper/sqliteHelper.dart';
import 'package:signingapp/web/httpServices/permissionsService.dart';
import 'baseService.dart';
import 'package:dio/dio.dart';

class EmpsLocationsServices extends BaseService {
  static Future<List<Locations>> getLocations(
      Map<String, String> authenticatedata) async {
    var bs = await Permission.checkPermissions(authenticatedata);
    var sharedPrefs = await SharedPreferences.getInstance();
    var empId = sharedPrefs.get("empId");
    var empCode = sharedPrefs.get("myCode");
    String query = "curEmp.id=$empId&curEmp.empCode=$empCode";
    int i = 0;
    if (bs["status"] == 200) {
      for (var per in bs["permsL"]) {
        if (query.trim().isNotEmpty) {
          query += "&";
        }
        query += "permsid[$i]=${per.toString()}";
        i++;
      }
    }

    Response response = await (BaseService.makeRequest(
        BaseService.baseUri + 'EmpsLocations?$query',
        mergeDefaultHeader: true,
        extraHeaders: {
          "Authorization":
              "Bearer ${base64Url.encode(utf8.encode('${authenticatedata["token"]}:${authenticatedata["username"]}:${authenticatedata["password"]}:${authenticatedata["ExpiryDate"]}'))}"
        },
        method: "GET"));
    var responseMap = response.data;
    await db.deleteLocs();
    for (var e in responseMap) {
      var i = e;
      await db.insertlocations(Locations(
          Id: i['id'],
          latitude: i['latitude'],
          lngtude: i['lngtude'],
          area: i['area'],
          address: i['address'],
          isParent: i['isParent'],
          waitingTime: i['waitingTime']));
    }
    List<Locations> mlocs = await db.locations();
    if (response.statusCode == 200) {
      return mlocs;
    } else {
      throw ('unknown Error Occured');
    }
  }
}
