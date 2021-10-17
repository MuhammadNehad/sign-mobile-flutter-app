part of 'attendings.dart';

class AttendingsAdapter extends TypeAdapter<Attendings> {
  final int _typeId = 3;
  @override
  Attendings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()
    };
    return Attendings();
  }

  @override
  int get typeId => _typeId.hashCode;

  @override
  void write(BinaryWriter writer, Attendings obj) {
    writer..writeByte(0);
  }
}

class AttendingsMethods {
  List<Attendings> emps = [];
  Future addAttendings(int Id, int empKey, DateTime atdt, bool entering,
      int locationKey, int leaveAfter) async {
    final attend = Attendings()
      ..Id = Id
      ..empKey = empKey
      ..leaveAfter = leaveAfter
      ..locationKey = locationKey
      ..entering = entering
      ..atdt = atdt;
    final box = Boxes.getAttendings();
    box.add(attend);

    // final box =Boxes.
  }

  void editAttendings(Attendings attend, int empKey, DateTime atdt,
      bool entering, int locationKey, int leaveAfter) {
    attend
      ..empKey = empKey
      ..leaveAfter = leaveAfter
      ..locationKey = locationKey
      ..entering = entering
      ..atdt = atdt;
    final box = Boxes.getAttendings();
    box.add(attend);
  }
}
