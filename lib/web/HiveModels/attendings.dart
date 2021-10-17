library signingapp.Attendings;

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:signingapp/web/Boxes.dart';
part 'attendingsAdapter.g.dart';

@HiveType(typeId: 3)
class Attendings extends HiveObject {
  @HiveField(0)
  int Id;
  @HiveField(1)
  int empKey;

  @HiveField(2)
  DateTime atdt;

  @HiveField(3)
  bool entering;

  @HiveField(4)
  int locationKey;

  @HiveField(5)
  int leaveAfter;

  Attendings(
      {this.atdt,
      this.empKey,
      this.entering,
      this.leaveAfter,
      this.locationKey});
  Attendings.fromJson(Map<String, dynamic> json)
      : atdt = json["atdt"],
        empKey = json["empKey"],
        entering = json["entering"],
        leaveAfter = json["leaveAfter"],
        Id = json["Id"],
        locationKey = json["locationKey"];
  Map<String, dynamic> toJson() {
    return {
      "atdt": atdt,
      "empKey": empKey,
      "entering": entering,
      "leaveAfter": leaveAfter,
      "locationKey": locationKey
    };
  }
}
