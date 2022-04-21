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
import 'package:signingapp/web/httpServices/employeeService.dart';
import 'package:signingapp/web/httpServices/locationsService.dart';
import 'package:synchronized/synchronized.dart';

import '../globals.dart';

Future<dbHelper> databascall() async {
  return dbHelper();
}

final _lock = Lock();
SharedPreferences sharedPrefs;
void callbackDispatcher() {
  const MethodChannel empLocService = MethodChannel("empLocService.Service");
  WidgetsFlutterBinding.ensureInitialized();
  try {
    empLocService.setMethodCallHandler((methodCall) async {
      try {
        sharedPrefs = await SharedPreferences.getInstance();
        List args = methodCall.arguments;
        // retreive callback instance for handle
        final Function callbackthis = PluginUtilities.getCallbackFromHandle(
            CallbackHandle.fromRawHandle(args[0]));
        assert(callbackthis != null);
        switch (methodCall.method) {
          case "saveLocations":
            await saveLocations();

            break;
          default:
            break;
        }
      } catch (e) {
        await sharedPrefs.remove("started Process....");
        print(e);
      }
      // callbackthis(args[0] as String);
    });
  } on PlatformException catch (e) {
    print(e.message);
    np.showNotification(e.message);
  }
}

Future<void> saveLocations() async {
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
        await EmpsServices.getEmplyeesViewServiceBCode(
            myCode, getAuthData(sharedPrefs));
        mlocs =
            await EmpsLocationsServices.getLocations(getAuthData(sharedPrefs));
      } else {
        mlocs = await db.locations();
      }
      l = await getLocation();

      if (mlocs.isNotEmpty && l.latitude != null && l.longitude != null) {
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
          if (sharedPrefs.containsKey("ShutDown") &&
              sharedPrefs.getBool("ShutDown")) {
            if (sharedPrefs.containsKey("shutdownTime")) {
              String shutdownTimeStr = sharedPrefs.getString("shutdownTime");
              DateTime shutdownTime = DateTime.parse(shutdownTimeStr);
              DateTime now = DateTime.now().toUtc().add(Duration(hours: 2));
              Duration shutdownTimediffer = now.difference(shutdownTime);
              if (shutdownTimediffer.inMinutes >= 20) {
                // await sharedPrefs.setBool(
                //     "entering", !sharedPrefs.getBool("entering"));
                await addAttendings(param4, empId, locid, sharedPrefs);
                if (attendingsL.length > 0) {
                  await addAttendings(
                      !attendingsL.last.entering, empId, locid, sharedPrefs,
                      natdt: shutdownTime.add(Duration(minutes: 20)));

                  param4 = !attendingsL.last.entering;
                } else {
                  await addAttendings(!param4, empId, locid, sharedPrefs,
                      natdt: shutdownTime.add(Duration(minutes: 20)));
                }
                await sharedPrefs.setBool(
                    "ShutDown", !sharedPrefs.getBool("ShutDown"));
                param4 = !param4;
              }
            }
          }
          // double distance = calculateDistance(
          //     locationData.latitude,
          //     locationData.longitude,
          //     elv.LocLatitude,
          //     elv.locLngtude);
          if (meters < mcloc.area) {
            await sharedPrefs.setString(
                "lastTimeInTheZone....", nowUTC.toString());

            if (attendingsL.length > 0) {
              if (attendingsL.last.entering == false) {
                if (!param4) {
                  await np.showNotification("${mcloc.address}, IN");
                  await addAttendings(param4, empId, locid, sharedPrefs);
                }
              }
            } else {
              if (!param4) {
                await sharedPrefs.setBool("adding....", true);
                await np.showNotification("${mcloc.address}, IN");

                await addAttendings(param4, empId, locid, sharedPrefs);
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
              await checkAndAddAttendings(aIn);
              Attendings aOut = Attendings();
              aOut
                ..empKey = empId
                ..locationKey = locid
                ..entering = true
                ..leaveAfter = 0
                ..atdt = DateTime(nowUTC.year, nowUTC.month, nowUTC.day);

              // elv.entering = a.entering;
              await checkAndAddAttendings(aOut);
            }
            attendingsL = await db.getAttendings();
            if (attendingsL.length > 0) {
              difference = lastTime.difference(nowUTC);
              if (difference.inMinutes >= (mcloc.waitingTime ?? 1200 / 60)) {
                if (attendingsL.last.entering == true) {
                  if (param4) {
                    await np.showNotification("${mcloc.address}, out");

                    await addAttendings(param4, empId, locid, sharedPrefs);
                  }
                }
              }
            } else {
              difference = datetime.difference(nowUTC);
              if (difference.inMinutes >= (mcloc.waitingTime ?? 1200 / 60)) {
                if (param4) {
                  await np.showNotification("${mcloc.address}, out");

                  await addAttendings(param4, empId, locid, sharedPrefs);
                }
              }
            }
          }
        } else {
          if (sharedPrefs.containsKey("locId") &&
              sharedPrefs.getInt("locId") != null &&
              sharedPrefs.getInt("locId") != 0) {
            datetime = sharedPrefs.containsKey("dateTime") &&
                    sharedPrefs.getString("dateTime") != null
                ? DateTime.parse(sharedPrefs.getString("dateTime"))
                : nowUTC;

            locid = sharedPrefs.getInt("locId");
            String mLocAddress = sharedPrefs.getString("locAddress");
            DateTime lastTime =
                DateTime.parse(sharedPrefs.getString("lastTimeInTheZone...."));

            if (sharedPrefs.containsKey("ShutDown") &&
                sharedPrefs.getBool("ShutDown")) {
              if (sharedPrefs.containsKey("shutdownTime")) {
                String shutdownTimeStr = sharedPrefs.getString("shutdownTime");
                DateTime shutdownTime = DateTime.parse(shutdownTimeStr);
                DateTime now = DateTime.now().toUtc().add(Duration(hours: 2));
                Duration shutdownTimediffer = now.difference(shutdownTime);
                if (shutdownTimediffer.inMinutes >= 20) {
                  // await sharedPrefs.setBool(
                  //     "entering", !sharedPrefs.getBool("entering"));
                  if (attendingsL.length > 0) {
                    await addAttendings(
                        attendingsL.last.entering, empId, locid, sharedPrefs,
                        natdt: shutdownTime.add(Duration(minutes: 20)));

                    param4 = !attendingsL.last.entering;
                  } else {
                    if (!sharedPrefs.containsKey("adding....")) {
                      await sharedPrefs.setBool("adding....", true);

                      await addAttendings(param4, empId, locid, sharedPrefs,
                          natdt: shutdownTime.add(Duration(minutes: 20)));
                    }
                  }
                  await sharedPrefs.setBool(
                      "ShutDown", !sharedPrefs.getBool("ShutDown"));
                  param4 = !param4;
                }
              }
            }

            attendingsL = await db.getAttendings();

            if (attendingsL.length > 0) {
              difference = lastTime.difference(nowUTC);
              if (difference.inMinutes.abs() >= (1200 / 60)) {
                if (attendingsL.last.entering == true) {
                  if (param4) {
                    if (mLocAddress != null) {
                      await np.showNotification("$mLocAddress, out");
                    }
                    await addAttendings(param4, empId, locid, sharedPrefs);
                  }
                }
              }
            } else {
              difference = nowUTC.difference(datetime);
              if (difference.inMinutes >= 1200 / 60) {
                if (param4) {
                  if (mLocAddress != null) {
                    await np.showNotification("$mLocAddress, out");
                  }
                  await addAttendings(param4, empId, locid, sharedPrefs);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      await sharedPrefs.remove("started Process....");
      print(e);
    }
    if (!sharedPrefs.containsKey("loading data....")) {
      sharedPrefs.setBool("loading data....", true);
      try {
        checkConnectivity();
      } catch (e) {
        await sharedPrefs.remove("adding....");
        await sharedPrefs.remove("started Process....");
        print(e);
      }
    }
    await sharedPrefs.remove("started Process....");
  }
  return 0;
}

Future<void> addAttendings(
    bool entering, int empId, int locid, SharedPreferences shared,
    {DateTime natdt}) async {
  natdt = natdt ?? DateTime.now().toUtc().add(Duration(hours: 2));
  Attendings a = Attendings();
  a
    ..empKey = empId
    ..locationKey = locid
    ..entering = !entering
    ..leaveAfter = 0
    ..atdt = natdt;

  // elv.entering = a.entering;
  await checkAndAddAttendings(a);
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
            bool succeeded = await AttendingsServices.add(
                attendings[i], getAuthData(sharedPrefs));
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

void checkingFunction() {}
Future<void> checkAndAddAttendings(Attendings attendings) async {
  await db.insertAttendings(attendings);
}

Future<Position> getLocation() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);
  return position;
}
