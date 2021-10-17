class Attendings {
  int Id;

  int empKey;

  DateTime atdt;

  bool entering;

  int locationKey;

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
      "atdt": atdt.toIso8601String(),
      "empKey": empKey,
      "entering": entering,
      "leaveAfter": leaveAfter,
      "locationKey": locationKey
    };
  }
}
