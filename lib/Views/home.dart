import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../globals.dart' as globals;

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (address().then((value) {
      return value;
    }, onError: () {
      return Scaffold(
        body: Center(
          child: Text('Location: not detected '),
        ),
      );
    }) as Widget);
  }

  Future<Widget> address() async {
    globals.shared = await SharedPreferences.getInstance();
    return Scaffold(
      body: Center(
        child: Text('Location: ${globals.shared.getString("locAddress")} '),
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
