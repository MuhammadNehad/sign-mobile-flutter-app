import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:signingapp/Modals/locations.dart';
import 'package:signingapp/services/connectionService.dart';
import 'package:signingapp/web/Boxes.dart';
import 'package:signingapp/web/HiveModels/EmpsLocsView.dart';
import 'package:signingapp/web/HiveModels/attendings.dart';
import 'package:signingapp/web/httpServices/attendingsService.dart';
import 'package:signingapp/web/httpServices/employeeService.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:signingapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../globals.dart' as globals;
import 'package:latlong/latlong.dart';

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var userlocation = Provider.of<locations>(context);
    // var pref = SharedPreferences.getInstance();
    // String myCode =
    //     globals.shared != null ? globals.shared.getString("myCode") : "";

    // globals.shared.setDouble("lat", userlocation.latitude);
    // globals.shared.setDouble("lon", userlocation.longtude);

    // if (!Hive.box<Emps_Locs_View>("Emps_Locs_View").isOpen) {
    //   Hive.openBox<Emps_Locs_View>("Emps_Locs_View");
    // }

    // if (globals.t1 == null) {
    //   // globals.t1 = Timer.periodic(Duration(seconds: 200), (t) async {
    //   //   // await EmpsServices.getEmplyeesViewServiceBCode(myCode!);
    //   // });
    // }
    // if (globals.t2 == null) {
    //   // globals.t2 = Timer.periodic(Duration(seconds: 20), (t) {
    //   // Emps_Locs_View elv =
    //   //     Hive.box<Emps_Locs_View>("Emps_Locs_View").get(myCode);
    //   // Box<Attendings> attendings = Boxes.getAttendings();
    //   // Attendings a = Attendings();
    //   // if (elv != null) {
    //   //   if (elv.LocLatitude != null &&
    //   //       elv.locLngtude != null &&
    //   //       globals.shared!.getDouble("lat") != null &&
    //   //       globals.shared!.getDouble("lon") != null) {
    //   //     Distance s = new Distance();
    //   //     num meters = s.as(
    //   //         LengthUnit.Meter,
    //   //         new LatLng(globals.shared!.getDouble("lat"),
    //   //             globals.shared!.getDouble("lon")),
    //   //         new LatLng(elv.LocLatitude, elv.locLngtude));
    //   //     double distance = calculateDistance(
    //   //         globals.shared!.getDouble("lat"),
    //   //         globals.shared!.getDouble("lon"),
    //   //         elv.LocLatitude,
    //   //         elv.locLngtude);

    //   //     if (distance.abs() < 20) {
    //   //       if (!elv.entering) {
    //   //         a
    //   //           ..empKey = elv.empId
    //   //           ..locationKey = elv.LOCID
    //   //           ..entering = !elv.entering
    //   //           ..leaveAfter = 0
    //   //           ..atdt = DateTime.now();
    //   //         checkAndAddAttendings(a);
    //   //       }
    //   //     } else {
    //   //       if (elv.entering) {
    //   //         a
    //   //           ..empKey = elv.empId
    //   //           ..locationKey = elv.LOCID
    //   //           ..entering = !elv.entering
    //   //           ..leaveAfter = 0
    //   //           ..atdt = DateTime.now();
    //   //         checkAndAddAttendings(a);
    //   //       }
    //   //     }
    //   //   }
    //   // }
    //   // });
    // }
    // Fluttertoast.showToast(
    //     msg: "tracking",
    //     toastLength: Toast.LENGTH_SHORT,
    //     gravity: ToastGravity.CENTER,
    //     timeInSecForIosWeb: 1,
    //     backgroundColor: Colors.red,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
    // db.insertEmployee(Employee(
    //     id: 1,
    //     name: "currentUser",
    //     phone: userlocation.latitude,
    //     longitude: userlocation.longtude));

    return Scaffold(
      body: Center(
        child: Text('Location: Lat: ,  Lat:  '),
      ),
    );
  }

  // void checkConnectivity() async {
  //   bool connected = await InternetConnection.checkConn();
  //   if (connected) {
  //     Box<Attendings> allAttendings = Boxes.getAttendings();

  //     for (int i = 0; i < allAttendings.length; i++) {
  //       try {
  //         bool succeeded = await AttendingsServices.add(allAttendings.getAt(i));
  //         if (succeeded) {
  //           allAttendings.deleteAt(i).then((value) => {});
  //         }
  //       } catch (e) {}
  //     }
  //   }
  // }

  // void checkAndAddAttendings(Attendings attendings) async {
  //   if (!Hive.box<Attendings>("Attendings").isOpen) {
  //     await Hive.openBox<Attendings>("Attendings");
  //   } else {
  //     await Hive.box<Attendings>("Attendings").put(
  //         attendings.empKey.toString() +
  //             attendings.locationKey.toString() +
  //             attendings.entering.toString(),
  //         attendings);
  //     checkConnectivity();
  //   }
  // }

  double calculateDistance(lat1, lng1, lat2, lng2) {
    double r = 6371; // Radius if the earth in km
    double dlat = deg2rad(lat2 - lat1);
    double dlng = deg2rad(lng2 - lng1);
    // double a = pow(sin(dlat / 2), 2) +
    //     (cos(deg2rad(lat1)) * cos(deg2rad(lat2))) +
    //     pow(sin(dlng / 2), 2);
    double a = 0.5 -
        dlat +
        cos(lat1 * pi) * cos(lat2 * pi) * (1 - cos((lng2 - lng1) * pi)) / 2;
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = r * c; //distance in KM
    double dm = d / 1000; //distance in meters
    return 12742 * asin(sqrt(a));
  }

  double deg2rad(double deg) {
    return cos(deg * pi) / 2;
  }
}
