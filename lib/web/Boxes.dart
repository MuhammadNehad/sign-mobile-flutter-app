import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:signingapp/web/HiveModels/Employee.dart';
import 'package:signingapp/web/HiveModels/attendings.dart';
import 'package:signingapp/web/HiveModels/empsLocations.dart';

import 'HiveModels/EmpsLocsView.dart';

class Boxes {
  static Box<Emplyee> getEmployees() => Hive.box<Emplyee>('employees');
  static Box<EmpsLocation> getEmpsLocation() =>
      Hive.box<EmpsLocation>('empsLocations');
  static Box<Emps_Locs_View> getEmps_Locs_View() =>
      Hive.box<Emps_Locs_View>('Emps_Locs_View');
  static Box<Attendings> getAttendings() => Hive.box<Attendings>('Attendings');
}
