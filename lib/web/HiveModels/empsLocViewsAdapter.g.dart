part of 'EmpsLocsView.dart';

class EmplyeeLocationsViewsAdapter extends TypeAdapter<Emps_Locs_View> {
  final int _typeId = 2;
  @override
  Emps_Locs_View read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()
    };
    return Emps_Locs_View();
  }

  @override
  int get typeId => _typeId.hashCode;

  @override
  void write(BinaryWriter writer, Emps_Locs_View obj) {
    writer..writeByte(0);
  }
}

class EmplyeeLocationsViewMethods {
  List<Emps_Locs_View> emps = [];
  Future addEmps_Locs_View(
      int locKey,
      String email,
      String name,
      String phone,
      double lat,
      double lng,
      String address,
      int empkey,
      int totalHours,
      bool entering,
      String empCode) async {
    final eEmpsLocsViewmp = Emps_Locs_View()
      ..LOCID = locKey
      ..empemail = email
      ..empId = empkey
      ..empName = name
      ..empPhone = phone
      ..LocLatitude = lat
      ..locLngtude = lng
      ..ELocaddress = address
      ..totalHours = totalHours
      ..entering = entering
      ..empCode = empCode;

    final box = Boxes.getEmps_Locs_View();
    box.add(eEmpsLocsViewmp);
    // final box =Boxes.
  }

  // ignore: non_constant_identifier_names
  void editEmps_Locs_View(
      Emps_Locs_View eEmpsLocsViewmp,
      int locKey,
      String email,
      String name,
      String phone,
      double lat,
      double lng,
      String address,
      int empkey,
      int totalHours,
      bool entering,
      String empCode) {
    eEmpsLocsViewmp
      ..LOCID = locKey
      ..empemail = email
      ..empId = empkey
      ..empName = name
      ..empPhone = phone
      ..LocLatitude = lat
      ..locLngtude = lng
      ..ELocaddress = address
      ..totalHours = totalHours
      ..entering = entering
      ..empCode = empCode;
    final box = Boxes.getEmps_Locs_View();
    box.add(eEmpsLocsViewmp);
  }
}
