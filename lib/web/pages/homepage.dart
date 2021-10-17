import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:signingapp/web/Boxes.dart';
import 'package:signingapp/web/HiveModels/Employee.dart';
import 'package:signingapp/web/HiveModels/EmpsLocsView.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Box<Emps_Locs_View> emps = Boxes.getEmps_Locs_View();

    return Scaffold(
      backgroundColor: Colors.brown,
      body: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
              // margin: EdgeInsets.fromLTRB(
              //     0, MediaQuery.of(context).size.height * 5 / 100, 0, 0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [Colors.brown[50], Colors.brown])),
              child: DataTable(
                  headingRowColor:
                      MaterialStateColor.resolveWith((states) => Colors.grey),
                  dataRowColor:
                      MaterialStateColor.resolveWith((states) => Colors.white),
                  columns: [
                    DataColumn(label: Text("name")),
                    DataColumn(label: Text("email")),
                    DataColumn(label: Text("phone")),
                    DataColumn(label: Text("location")),
                  ],
                  rows: List<DataRow>.generate(
                      (emps != null ? emps.length : 0),
                      (index) => DataRow(cells: [
                            DataCell(Text(emps.getAt(index).empName ?? "")),
                            DataCell(Text(emps.getAt(index).empemail ?? "")),
                            DataCell(Text(emps.getAt(index).empPhone ?? "")),
                            DataCell(Text(emps.getAt(index).ELocaddress ?? ""))
                          ]))))),
    );
  }
}
