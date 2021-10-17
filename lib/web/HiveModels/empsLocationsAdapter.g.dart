part of 'empsLocations.dart';

class EmplyeeLocationsAdapter extends TypeAdapter<EmpsLocation> {
  final int _typeId = 1;
  @override
  EmpsLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()
    };
    return EmpsLocation();
  }

  @override
  int get typeId => _typeId.hashCode;

  @override
  void write(BinaryWriter writer, EmpsLocation obj) {
    writer..writeByte(0);
  }
}

class EmpsLocationsMethods {
  List<EmpsLocation> emps = [];
  Future addEmployee(
      double lat, double lng, String address, String empkey) async {
    final emp = EmpsLocation()
      ..langtude = lng
      ..latitude = lat
      ..address = address
      ..empKey = empkey;
    final box = Boxes.getEmpsLocation();
    box.add(emp);

    // final box =Boxes.
  }

  void editEmployee(
      EmpsLocation emp, double lat, double lng, String address, String empkey) {
    emp
      ..langtude = lng
      ..latitude = lat
      ..address = address
      ..empKey = empkey;
    final box = Boxes.getEmpsLocation();
    box.add(emp);
  }
}
