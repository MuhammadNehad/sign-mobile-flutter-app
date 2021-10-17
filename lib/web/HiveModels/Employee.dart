library signingapp.Emplyee;

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:signingapp/web/Boxes.dart';
part 'employeeAdapter.g.dart';

@HiveType(typeId: 0)
class Emplyee extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String email;

  @HiveField(4)
  int locationKey;

  Emplyee({this.id, this.name, this.phone, this.email, this.locationKey});
}
