import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:signingapp/Modals/EmpsLocsView.dart';
import 'package:signingapp/backgroundTasks/runInbackGround.dart';
import 'package:signingapp/dbHelper/sqliteHelper.dart';
import 'package:signingapp/services/connectionService.dart';
import 'Modals/UserLogin.dart';
import 'web/httpServices/employeeService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'viewHelpers/notifications.dart';
import 'package:location/location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  globals.shared = await SharedPreferences.getInstance();
  print("has shutdown:${globals.shared.containsKey("ShutDown")}");
  print("has shutdown:${globals.shared.getBool("ShutDown")}");
  await globals.shared.setBool("still_running", false);

  // const MethodChannel empLocServiceReq =
  //     MethodChannel("empLocService.LocRationalPerm");
  // await empLocServiceReq.invokeMethod("getBackGroundReq");
// You can can also directly ask the permission about its status.

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

locationService() async {
  Location location = new Location();

  location.serviceEnabled().then((_serviceEnabled) async {
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    PermissionStatus pGranted = await location.hasPermission();
    if (pGranted == PermissionStatus.denied ||
        pGranted == PermissionStatus.deniedForever) {
      // await AppSettings.openLocationSettings(asAnotherTask: true);
      pGranted = await location.hasPermission();
      if (pGranted == PermissionStatus.denied ||
          pGranted == PermissionStatus.deniedForever) {
        pGranted = await location.requestPermission();
        if (pGranted == PermissionStatus.granted ||
            pGranted == PermissionStatus.grantedLimited) {
          location.enableBackgroundMode(enable: true);
        }
      } else {
        location.enableBackgroundMode(enable: true);
      }
    } else {
      location.enableBackgroundMode(enable: true);
    }
  });
}

Future<void> locService() async {}

Future<Emps_Locs_View> checkHiveBox(String myCOde) async {
  Emps_Locs_View hemlv = Emps_Locs_View();

  if (hemlv == null || hemlv.empCode == null) {
    bool conn = await InternetConnection.checkConn();
    if (conn) {
      hemlv = await EmpsServices.getEmplyeesViewServiceBCode(
          myCOde, globals.getAuthData(globals.shared));
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
    np.setOnNotificationClick((p) {});
    super.initState();
    // saveLocations();
    // initEmplyee();
    locationService();
    RunDartInBackground.initialize();
  }

  Future<Emps_Locs_View> checkEmpinBox(String myCode) async {
    bool checkconnected = await InternetConnection.checkConn();
    if (checkconnected) {
      await EmpsServices.getEmplyeesViewServiceBCode(
          myCode, globals.getAuthData(globals.shared));
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
    return Scaffold(
      body: Center(
        child: Container(
          child: Center(child: Text("testing geofence")),
        ),
      ),
    );
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
          child: Text("Make Sure You are registered By HR"),
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
      debugShowCheckedModeBanner: false,
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
  String code;
  String pass;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String myCOde = globals.shared.getString("myCode");
    String token = globals.shared.getString("usertoken");
    locationService();
    MethodChannel nativepermissions = MethodChannel("permissions");
    try {
      nativepermissions
          .invokeMethod("LocationPermission")
          .then((value) => {print(value)});
    } on PlatformException catch (e) {
      print(e);
    }
    InternetConnection.checkConn().then((value) {
      if (value) {
        EmpsServices.getEmplyeesViewServiceBCode(
                myCOde, globals.getAuthData(globals.shared))
            .then((value) => {
                  value != null &&
                          value.empCode != null &&
                          token != null &&
                          token.isNotEmpty
                      ? Navigator.of(context).pushNamed("main")
                      : {
                          // showDialog(
                          //     context: context,
                          //     builder: (builder) => UnRegisteredView())
                        }
                });
      } else if (!value &&
          myCOde != null &&
          myCOde.isNotEmpty &&
          myCOde.isNotEmpty &&
          token != null &&
          token.isNotEmpty) {
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
                      obscureText: true,
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
                                EmpsServices.login(UserLogin(code, pass))
                                    .then((value) {
                                  if (value) {
                                    EmpsServices.getEmplyeesViewServiceBCode(
                                            code,
                                            globals.getAuthData(globals.shared))
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
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
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
