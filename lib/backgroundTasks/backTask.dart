import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signingapp/Modals/locations.dart';
import 'package:signingapp/dbHelper/sqliteHelper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signingapp/Modals/attendings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signingapp/viewHelpers/notifications.dart';
import 'package:latlong/latlong.dart';
import 'package:signingapp/services/connectionService.dart';
import 'package:signingapp/web/httpServices/attendingsService.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signingapp/web/httpServices/employeeService.dart';
import 'package:signingapp/web/httpServices/locationsService.dart';
import 'package:synchronized/synchronized.dart';

Future<dbHelper> databascall() async {
  return dbHelper();
}

final _lock = Lock();

void callbackDispatcher() {
  const MethodChannel empLocService = MethodChannel("empLocService.Service");
  WidgetsFlutterBinding.ensureInitialized();
  try {
    empLocService.setMethodCallHandler((methodCall) async {
      var sharedPrefs = await SharedPreferences.getInstance();
      List args = methodCall.arguments;
      // retreive callback instance for handle
      final Function callbackthis = PluginUtilities.getCallbackFromHandle(
          CallbackHandle.fromRawHandle(args[0]));
      assert(callbackthis != null);
      switch (methodCall.method) {
        case "saveLocations":
          if (await Permission.location.isRestricted) {
            Map<Permission, PermissionStatus> statuses = await [
              Permission.location,
            ].request();
            // The OS restricts access, for example because of parental controls.
            // BackgroundLocation.startLocationService(distanceFilter: 10.0);
          } else {
            // BackgroundLocation.startLocationService(distanceFilter: 0.0);
            // BackgroundLocation.setAndroidConfiguration(4);
          }
          saveLocations();

          break;
        default:
          break;
      }
      // callbackthis(args[0] as String);
    });
  } on PlatformException catch (e) {
    print(e.message);
  }
}

void saveLocations() async {
  var sharedPrefs = await SharedPreferences.getInstance();

  if (!sharedPrefs.containsKey("started Process....")) {
    sharedPrefs.setBool("started Process....", true);

    try {
      String myCode;
      Position l;

      Locations mcloc;
      bool param4;
      int empId;
      int locid;
      DateTime datetime;
      List<Locations> mlocs;
      List<Attendings> attendingsL = await db.getAttendings();
      Duration difference;
      Distance s = new Distance();
      myCode = sharedPrefs.getString("myCode");
      bool connected = await InternetConnection.checkConn();
      if (connected) {
        await EmpsServices.getEmplyeesViewServiceBCode(myCode);
        mlocs = await EmpsLocationsServices.getLocations();
      } else {
        mlocs = await db.locations();
      }
      l = await getLocation();

      if (mlocs.isNotEmpty && l.latitude != null && l.longitude != null) {
        var metT = s
            .as(
                LengthUnit.Meter,
                new LatLng(30.075397371612784, 31.64544648610287),
                new LatLng(l.latitude, l.longitude))
            .abs();
        mcloc = mlocs.firstWhere(
            (mloc) =>
                s
                    .as(
                        LengthUnit.Meter,
                        new LatLng(mloc.latitude, mloc.lngtude),
                        new LatLng(l.latitude, l.longitude))
                    .abs() <=
                mloc.area,
            orElse: () => null);
        param4 = sharedPrefs.getBool("entering");
        empId = sharedPrefs.getInt("empId");
        DateTime nowUTC = DateTime.now().toUtc().add(Duration(hours: 2));
        if (mcloc != null) {
          locid = mcloc.Id;
          sharedPrefs.setInt("locId", locid);
          sharedPrefs.setString("locAddress", mcloc.address);

          print("loc ${mcloc.latitude},${mcloc.lngtude}");
          num meters = s.as(
              LengthUnit.Meter,
              new LatLng(mcloc.latitude, mcloc.lngtude),
              new LatLng(l.latitude, l.longitude));

          print("distance $meters");
          // double distance = calculateDistance(
          //     locationData.latitude,
          //     locationData.longitude,
          //     elv.LocLatitude,
          //     elv.locLngtude);
          if (meters < mcloc.area) {
            await sharedPrefs.setString(
                "lastTimeInTheZone....", nowUTC.toString());

            await np.showNotification("${mcloc.address}, IN");
            if (attendingsL.length > 0) {
              if (attendingsL.last.entering == false) {
                if (!param4) {
                  if (!sharedPrefs.containsKey("adding....")) {
                    await sharedPrefs.setBool("adding....", true);
                    addAttendings(param4, empId, locid, sharedPrefs);
                  }
                }
              }
            } else {
              if (!param4) {
                if (!sharedPrefs.containsKey("adding....")) {
                  await sharedPrefs.setBool("adding....", true);

                  addAttendings(param4, empId, locid, sharedPrefs);
                }
              }
            }
          } else {
            DateTime lastTime =
                DateTime.parse(sharedPrefs.getString("lastTimeInTheZone...."));
            if (nowUTC.day != lastTime.day) {
              Attendings aIn = Attendings();
              aIn
                ..empKey = empId
                ..locationKey = locid
                ..entering = false
                ..leaveAfter = 0
                ..atdt =
                    DateTime(nowUTC.year, nowUTC.month, nowUTC.day - 1, 11, 59);

              // elv.entering = a.entering;
              checkAndAddAttendings(aIn);
              Attendings aOut = Attendings();
              aOut
                ..empKey = empId
                ..locationKey = locid
                ..entering = true
                ..leaveAfter = 0
                ..atdt = DateTime(nowUTC.year, nowUTC.month, nowUTC.day);

              // elv.entering = a.entering;
              checkAndAddAttendings(aOut);
            }
            attendingsL = await db.getAttendings();
            await np.showNotification("${mcloc.address}, out");
            if (attendingsL.length > 0) {
              difference = lastTime.difference(nowUTC);
              if (difference.inMinutes >= (mcloc.waitingTime / 60)) {
                if (attendingsL.last.entering == true) {
                  if (param4) {
                    if (!sharedPrefs.containsKey("adding....")) {
                      await sharedPrefs.setBool("adding....", true);

                      addAttendings(param4, empId, locid, sharedPrefs);
                    }
                  }
                }
              }
            } else {
              difference = datetime.difference(nowUTC);
              if (difference.inMinutes >= (mcloc.waitingTime / 60)) {
                if (param4) {
                  if (!sharedPrefs.containsKey("adding....")) {
                    await sharedPrefs.setBool("adding....", true);

                    addAttendings(param4, empId, locid, sharedPrefs);
                  }
                }
              }
            }
          }
        } else {
          if (sharedPrefs.containsKey("locId") &&
              sharedPrefs.getInt("locId") != null) {
            datetime = sharedPrefs.getString("dateTime") != null
                ? DateTime.parse(sharedPrefs.getString("dateTime"))
                : nowUTC;

            locid = sharedPrefs.getInt("locId");
            String mLocAddress = sharedPrefs.getString("locAddress");
            DateTime lastTime =
                DateTime.parse(sharedPrefs.getString("lastTimeInTheZone...."));
            if (nowUTC.day != lastTime.day) {
              Attendings aIn = Attendings();
              aIn
                ..empKey = empId
                ..locationKey = locid
                ..entering = false
                ..leaveAfter = 0
                ..atdt =
                    DateTime(nowUTC.year, nowUTC.month, nowUTC.day - 1, 11, 59);

              // elv.entering = a.entering;
              checkAndAddAttendings(aIn);
              Attendings aOut = Attendings();
              aOut
                ..empKey = empId
                ..locationKey = locid
                ..entering = true
                ..leaveAfter = 0
                ..atdt = DateTime(nowUTC.year, nowUTC.month, nowUTC.day);

              // elv.entering = a.entering;
              checkAndAddAttendings(aOut);
            }
            attendingsL = await db.getAttendings();
            await np.showNotification("$mLocAddress, out");
            if (attendingsL.length > 0) {
              difference = lastTime.difference(nowUTC);
              if (difference.inMinutes >= (mcloc.waitingTime / 60)) {
                if (attendingsL.last.entering == true) {
                  if (param4) {
                    if (!sharedPrefs.containsKey("adding....")) {
                      await sharedPrefs.setBool("adding....", true);

                      addAttendings(param4, empId, locid, sharedPrefs);
                    }
                  }
                }
              }
            } else {
              difference = datetime.difference(nowUTC);
              if (difference.inMinutes >= (mcloc.waitingTime / 60)) {
                if (param4) {
                  if (!sharedPrefs.containsKey("adding....")) {
                    await sharedPrefs.setBool("adding....", true);

                    addAttendings(param4, empId, locid, sharedPrefs);
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      await sharedPrefs.remove("adding....");
      await sharedPrefs.remove("started Process....");
      await np.showNotification(e);

      throw (e);
    }
    if (!sharedPrefs.containsKey("loading data....")) {
      sharedPrefs.setBool("loading data....", true);
      checkConnectivity();
    }
    await sharedPrefs.remove("started Process....");
  }
}

void addAttendings(
    bool entering, int empId, int locid, SharedPreferences shared) {
  Attendings a = Attendings();
  a
    ..empKey = empId
    ..locationKey = locid
    ..entering = !entering
    ..leaveAfter = 0
    ..atdt = DateTime.now().toUtc().add(Duration(hours: 2));

  // elv.entering = a.entering;
  checkAndAddAttendings(a);
}

void checkConnectivity() async {
  await _lock.synchronized(() async {
    var sharedPrefs = await SharedPreferences.getInstance();
    bool connected = await InternetConnection.checkConn();
    if (connected) {
      databascall().then((value) async {
        List<Attendings> attendings = await value.getAttendings();

        for (int i = 0; i < attendings.length; i++) {
          try {
            bool succeeded = await AttendingsServices.add(attendings[i]);
            if (succeeded) {
              await db.deleteAttendings(attendings[i]);
            }
          } catch (e) {
            await sharedPrefs.remove("loading data....");
          }
        }
        await sharedPrefs.remove("loading data....");
      });
    }
    await sharedPrefs.remove("loading data....");
  });
}

void checkAndAddAttendings(Attendings attendings) async {
  await db.insertAttendings(attendings);
}

Future<dynamic> initEmplyee() async {}
Future<Position> getLocation() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);
  return position;
}
