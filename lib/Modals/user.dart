class Employee {
  int id;
  String name;
  String phone;
  String email;

  int locationKey;
  Employee({this.id, this.name, this.email, this.phone, this.locationKey});
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'locationKey': locationKey,
    };
  }
}
