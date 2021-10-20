import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:signingapp/Modals/EmpsLocsView.dart';
import 'package:signingapp/backgroundTasks/runInbackGround.dart';

import 'package:signingapp/dbHelper/sqliteHelper.dart';

import 'package:signingapp/services/connectionService.dart';
import 'package:signingapp/web/httpServices/permissionsService.dart';

import 'web/httpServices/employeeService.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'viewHelpers/notifications.dart';
import 'package:location/location.dart';
import 'package:app_settings/app_settings.dart';

Location location = new Location();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  globals.shared = await SharedPreferences.getInstance();

  await globals.shared.setBool("still_running", false);

  bool _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  // const MethodChannel empLocServiceReq =
  //     MethodChannel("empLocService.LocRationalPerm");
  // await empLocServiceReq.invokeMethod("getBackGroundReq");
// You can can also directly ask the permission about its status.

  PermissionStatus pGranted = await location.hasPermission();
  if (pGranted == PermissionStatus.denied) {
    // await AppSettings.openLocationSettings(asAnotherTask: true);
    pGranted = await location.hasPermission();
    if (pGranted == PermissionStatus.denied) {
      pGranted = await location.requestPermission();
      if (pGranted == PermissionStatus.granted) {
        await location
            .enableBackgroundMode(enable: true)
            .whenComplete(() => {});
      }
    }
  }
  runApp(ValidateMyCode());

  // ph.Permission k = ph.Permission.locationAlways;
  // if (Platform.isAndroid) {
  //   var t = await k.shouldShowRequestRationale;
  //   if (t) {
  //     ph.PermissionStatus pAGranted = await k.request();
  //     if (pAGranted != ph.PermissionStatus.granted) {
  //       return;
  //     }
  //   }
  // }
//  await EmpsServices.getEmplyeesViewService();
}

Future<void> locService() async {}

Future<Emps_Locs_View> checkHiveBox(String myCOde) async {
  Emps_Locs_View hemlv = Emps_Locs_View();

  if (hemlv == null || hemlv.empCode == null) {
    bool conn = await InternetConnection.checkConn();
    if (conn) {
      hemlv = await EmpsServices.getEmplyeesViewServiceBCode(myCOde);
      return hemlv;
    }
  }
  return null;
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  MyAppView createState() => MyAppView();
}

class MyAppView extends State<MyApp> {
  String geofenceState = 'N/A';
  List<String> registeredGeofences = [];

  double radius = 100;
  @override
  void initState() {
    // TODO: implement initState
    np.setOnNotificationClick((p) {});
    super.initState();
    // saveLocations();
    // initEmplyee();
    RunDartInBackground.initialize();
  }

  Future<dynamic> methodHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case "saveLocations":
        List args = methodCall.arguments;
        // saveLocations(
        //     args[0], Location(args[1][0], args[1][1]), args[3], args[2]);
        break;
      default:
    }
    return new Future.value("");
  }

  Future<Emps_Locs_View> checkEmpinBox(String myCode) async {
    bool checkconnected = await InternetConnection.checkConn();
    if (checkconnected) {
      await EmpsServices.getEmplyeesViewServiceBCode(myCode);
    }
    List<Emps_Locs_View> hemlvL = (await db.empsLocsViewByCode(myCode));
    Emps_Locs_View empv = Emps_Locs_View();
    if (hemlvL.length > 0) {
      empv = hemlvL.last;
    }

    return empv;
  }

  @override
  Widget build(BuildContext context) {
    // checkHiveBoxV();
    // GeofencingManager.getRegisteredGeofenceIds().then((value) {
    //   registeredGeofences = value;
    //   if (registeredGeofences.length > 0) {}
    // });

    // locations? lastone;
    int locationslength = 0;
    // LocationService()
    //     .locationStream.
    //     .length
    //     .then((value) => locationslength = value);
    // LocationService().locationStream.timeout(Duration(seconds: 30));
    // if (locationslength > 0) {
    //   LocationService().locationStream.last.then((value) => lastone = value);
    // } else {
    //   lastone = new locations(latitude: 0, longtude: 0);
    // }
    return Scaffold(
      body: Center(
        child: Container(
          child: Center(child: Text("testing geofence")),
        ),
      ),
    );

    // StreamProvider<locations?>(
    //   initialData: lastone,
    //   create: (context) => LocationService().locationStream,
    //   child: Home(),
    // );
  }

  Future<Widget> address() async {
    globals.shared = await SharedPreferences.getInstance();
    return Scaffold(
      body: Center(
        child: Text('Location: ${globals.shared.getString("locAddress")} '),
      ),
    );
  }
}

class UnRegisteredView extends StatefulWidget {
  const UnRegisteredView({Key key}) : super(key: key);

  @override
  _UnRegisteredViewState createState() => _UnRegisteredViewState();
}

class _UnRegisteredViewState extends State<UnRegisteredView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
            child: Container(
          child: Text("make Sure You are registered in the company"),
        )));
  }
}

// validate EmpCode
class ValidateMyCode extends StatefulWidget {
  const ValidateMyCode({Key key}) : super(key: key);

  @override
  _ValidateMyCodeState createState() => _ValidateMyCodeState();
}

class _ValidateMyCodeState extends State<ValidateMyCode> {
  bool finished = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
      routes: {
        "main": (BuildContext context) => MyApp(),
      },
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _formPKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  String code;
  String pass;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String myCOde = globals.shared.getString("myCode");

    InternetConnection.checkConn().then((value) {
      if (value) {
        EmpsServices.getEmplyeesViewServiceBCode(myCOde).then((value) => {
              value != null && value.empCode != null
                  ? Navigator.of(context).pushNamed("main")
                  : {}
            });
      } else if (!value && myCOde != null && myCOde.isNotEmpty) {
        // Future.delayed(Duration(seconds: 4), () {
        //   Navigator.push(context, MaterialPageRoute(builder: (con) => MyApp()));
        // });
        Fluttertoast.showToast(
            msg: "No Internet Connection ",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        Future.delayed(
            Duration.zero, () => Navigator.of(context).pushNamed("main"));
      }
    });

    return Scaffold(
        body: Container(
      color: Colors.amber,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "Enter Code",
                          border: new OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                  style: BorderStyle.solid))),
                      validator: (val) {
                        //validate field is filled
                        if (val == null || val.isEmpty) {
                          return "field must be filled";
                        } else {
                          code = val;
                          //CheckIfFutureFinished.syncCheckIfFinished();
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          hintText: "Enter Password",
                          border: new OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1,
                                  style: BorderStyle.solid))),
                      validator: (val) {
                        //validate field is filled
                        if (val == null || val.isEmpty) {
                          return "field must be filled";
                        } else {
                          pass = val;
                          //CheckIfFutureFinished.syncCheckIfFinished();
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            InternetConnection.checkConn().then((value) {
                              if (value) {
                                EmpsServices.login(code, pass).then((value) {
                                  if (value) {
                                    EmpsServices.getEmplyeesViewServiceBCode(
                                            code)
                                        .then((value) => {
                                              value != null &&
                                                      value.empCode != null
                                                  ? Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (con) =>
                                                              MyApp()))
                                                  : {}
                                            });
                                  }
                                });
                              }
                            });
                          }
                        },
                        child: Text("Submit")),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    // TODO: implement createHttpClient
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    ;
  }
}

class CheckIfFutureFinished {
  static bool isFinished = false;
  static void asyncCheckIfFinished() {
    Future.delayed(
        Duration(seconds: 1),
        () => {
              if (!isFinished)
                {asyncCheckIfFinished()}
              else
                {isFinished = false}
            });
  }

  static void syncCheckIfFinished() {
    while (!isFinished) {
      sleep(Duration(milliseconds: 300));
    }
    isFinished = false;
  }
}
