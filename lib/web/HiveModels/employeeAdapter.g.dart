part of 'Employee.dart';

class EmplyeeAdapter extends TypeAdapter<Emplyee> {
  final int _typeId = 0;
  @override
  Emplyee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()
    };
    return Emplyee();
  }

  @override
  int get typeId => _typeId.hashCode;

  @override
  void write(BinaryWriter writer, Emplyee obj) {
    writer..writeByte(0);
  }
}

class EmployeeMethods {
  List<Emplyee> emps = [];
  Future addEmployee(String name, String phone, String email) async {
    final emp = Emplyee()
      ..name = name
      ..email = email
      ..phone = phone;
    final box = Boxes.getEmployees();
    box.add(emp);

    // final box =Boxes.
  }

  void editEmployee(Emplyee emp, String name, String phone, String email) {
    emp
      ..name = name
      ..email = email
      ..phone = phone;
    final box = Boxes.getEmployees();
    box.add(emp);
  }
}
