import 'package:flutter/material.dart';
import 'package:signingapp/web/HiveModels/empsLocations.dart';
import 'package:signingapp/web/Boxes.dart';
import 'package:signingapp/web/HiveModels/Employee.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:signingapp/web/httpServices/employeeService.dart';
import 'HiveModels/EmpsLocsView.dart';
import 'pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(EmplyeeAdapter());
  Hive.registerAdapter(EmplyeeLocationsViewsAdapter());

  await Hive.openBox<Emplyee>('employees');
  await Hive.openBox<EmpsLocation>('empsLocations');
  await Hive.openBox<Emps_Locs_View>('Emps_Locs_View');

  await EmpsServices.getEmplyeesViewService();
  runApp(StartPoint());
}

class StartPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
