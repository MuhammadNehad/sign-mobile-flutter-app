class Emps_Locs_View {
  int empId;
  String empemail;
  String empName;
  String empPhone;
  String ELocaddress;
  double LocLatitude;
  double locLngtude;
  bool entering;
  int totalHours;
  DateTime dateTime;
  String empCode;
  int LOCID;
  Emps_Locs_View(
      {this.empId,
      this.empemail,
      this.empName,
      this.empPhone,
      this.ELocaddress,
      this.LocLatitude,
      this.locLngtude,
      this.LOCID,
      this.entering,
      this.totalHours,
      this.empCode});

  Emps_Locs_View.fromMap(Map<String, dynamic> res)
      : empId = res["empId"],
        empemail = res["empemail"],
        empName = res["empName"],
        empPhone = res["empPhone"],
        ELocaddress = res["eLocaddress"],
        LocLatitude = res["locLatitude"],
        locLngtude = res["locLngtude"],
        dateTime = DateTime.parse(res["dateTime"]),
        LOCID = res["LOCID".toLowerCase()],
        entering = res["entering"],
        totalHours = res["totalHours"],
        empCode = res["empCode"];

  Map<String, dynamic> toMap() {
    return {
      "empId": this.empId,
      "empemail": this.empemail,
      "empName": this.empName,
      "empPhone": this.empPhone,
      "ELocaddress": this.ELocaddress,
      "LocLatitude": this.LocLatitude,
      "locLngtude": this.locLngtude,
      "dateTime": this.dateTime,
      "LOCID": this.LOCID,
      "entering": this.entering,
      "totalHours": this.totalHours,
      "empCode": this.empCode
    };
  }
}
