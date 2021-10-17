library signingapp.EmpsLocation;

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:signingapp/web/Boxes.dart';
part 'empsLocationsAdapter.g.dart';

@HiveType(typeId: 1)
class EmpsLocation extends HiveObject {
  @HiveField(0)
  int Id;

  @HiveField(1)
  double latitude;

  @HiveField(2)
  double langtude;

  @HiveField(3)
  String empKey;

  @HiveField(4)
  String address;
}
