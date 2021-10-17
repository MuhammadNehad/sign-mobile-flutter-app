// ignore: library_names
library locationrecorder.Emps_Locs_View;

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:signingapp/web/Boxes.dart';
part 'empsLocViewsAdapter.g.dart';

@HiveType(typeId: 2)
class Emps_Locs_View extends HiveObject {
  @HiveField(0)
  int empId;
  @HiveField(1)
  String empemail;
  @HiveField(2)
  String empName;
  @HiveField(3)
  String empPhone;
  @HiveField(4)
  String ELocaddress;
  @HiveField(5)
  double LocLatitude;
  @HiveField(6)
  double locLngtude;
  @HiveField(7)
  int LOCID;
  @HiveField(8)
  int totalHours;
  @HiveField(9)
  bool entering;
  @HiveField(10)
  String empCode;
}
