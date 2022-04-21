// ignore_for_file: non_constant_identifier_names

class Locations {
  int Id;
  double latitude;
  double lngtude;
  String address;
  bool isParent;
  num area;
  num waitingTime;
  Locations(
      {this.Id,
      this.latitude,
      this.lngtude,
      this.address,
      this.area,
      this.isParent,
      this.waitingTime});

  Locations.fromJson(Map<String, dynamic> json)
      : latitude = json["latitude"],
        lngtude = json["lngtude"],
        address = json["address"],
        area = json["area"],
        Id = json["Id"],
        waitingTime = json["waitingTime"],
        isParent = json["isParent"];
  Map<String, dynamic> toJson() {
    return {
      "Id": Id,
      "latitude": latitude,
      "lngtude": lngtude,
      "address": address,
      "area": area,
      "isParent": isParent ? 1 : 0,
      "waitingTime": waitingTime
    };
  }
}
