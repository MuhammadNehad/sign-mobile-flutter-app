import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:signingapp/Modals/EmpsLocsView.dart';
import 'package:signingapp/Modals/attendings.dart';
import 'package:signingapp/Modals/locations.dart';
import 'package:signingapp/Modals/user.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

class dbHelper {
  final _lock = Lock();
  static Database _database;

  dbHelper() {
    this.database();
  }
  Future<Database> database() async {
    _database = await _initdataBase("Employee_database");
    return _database;
  }

  Future<Database> _initdataBase(String dbName) async {
    // Open the database and store the reference.
    return openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), dbName + '.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute(
          '''CREATE TABLE IF NOT EXISTS Employees(id INT PRIMARY KEY, name VARCHAR(1000), phone VARCHAR(1000),email VARCHAR(1000),locationKey INT)''',
        );
        await db.execute(
            '''CREATE TABLE IF NOT EXISTS Emps_Locs_Views(empId  INT  ,empemail VARCHAR(1000) ,empName   VARCHAR(1000),empPhone  VARCHAR(1000),ELocaddress VARCHAR(1000),LocLatitude REAL,locLngtude REAL,LOCID INT,entering  TINYINT,totalHours BIGINT,empCode VARCHAR(1000))''');
        await db.execute(
          '''CREATE TABLE IF NOT EXISTS attendings(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            empKey INT,
           atdt DATETIME,
            entering TINYINT,
            locationKey INT,
            leaveAfter BIGINT)''',
        );
        await db.execute(
          '''CREATE TABLE IF NOT EXISTS Locations(Id INT, latitude REAL, lngtude REAL, address TEXT,isParent INTEGER, area INTEGER,waitingTime INTEGER)''',
        );

        return db;
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future close() async {
    await _database.close();
  }

//insert employees
  Future<void> insertEmployee(Employee emp) async {
    await _database.insert(
      'Employees',
      emp.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

//retrieve employees
  Future<List<Employee>> employees() async {
    final List<Map<String, Object>> maps = await _database.query('Employees');

    return List.generate(maps.length, (i) {
      return Employee(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        phone: maps[i]['phone'] as String,
        locationKey: maps[i]['locationKey'] as int,
      );
    });
  }

//retrieve employees
  Future<List<Employee>> employeesByPhone(String phone) async {
    final List<Map<String, Object>> maps =
        await _database.query('Employees', where: "phone =" + phone);
    return List.generate(maps.length, (i) {
      return Employee(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        phone: maps[i]['phone'] as String,
        locationKey: maps[i]['locationKey'] as int,
      );
    });
  }

  Future<void> updateEmp(Employee emp) async {
    final db = _database;
    await db
        .update('Employees', emp.toMap(), where: 'id = ?', whereArgs: [emp.id]);
  }

  Future<void> deleteEmp(Employee emp) async {
    await _lock.synchronized(() async {
      final db = _database;
      await db.delete('Employees', where: 'id = ?', whereArgs: [emp.id]);
    });
  }

  Future<void> insertEmps_Locs_View(Emps_Locs_View emp) async {
    final db = _database;
    await _lock.synchronized(() async {
      await db.insert(
        'Emps_Locs_Views',
        emp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

//retrieve employees
  Future<List<Emps_Locs_View>> getEmpsLocsView() async {
    final db = _database;
    final List<Map<String, Object>> maps = await db.query('Emps_Locs_Views');
    return List.generate(maps.length, (i) {
      return Emps_Locs_View(
        empId: maps[i]["empId"],
        empemail: maps[i]["empemail"],
        empName: maps[i]["empName"],
        empPhone: maps[i]["empPhone"],
        ELocaddress: maps[i]["ELocaddress"],
        LocLatitude: maps[i]["LocLatitude"],
        locLngtude: maps[i]["locLngtude"],
        LOCID: maps[i]["LOCID"],
        entering: maps[i]["entering"] == 1 ? true : false,
        totalHours: maps[i]["totalHours"],
        empCode: maps[i]["empCode"],
      );
    });
  }

//retrieve employees
  Future<List<Emps_Locs_View>> empsLocsViewByCode(String empCode) async {
    final db = _database;
    final List<Map<String, dynamic>> maps = await Future.delayed(
        Duration(seconds: 4),
        () => db != null
            ? db.query('Emps_Locs_Views', where: "empCode =" + empCode)
            : [{}]);
    return List.generate(maps.length, (i) {
      return Emps_Locs_View(
        empId: maps[i]["empId"],
        empemail: maps[i]["empemail"],
        empName: maps[i]["empName"],
        empPhone: maps[i]["empPhone"],
        ELocaddress: maps[i]["ELocaddress"],
        LocLatitude: maps[i]["LocLatitude"],
        locLngtude: maps[i]["locLngtude"],
        LOCID: maps[i]["LOCID"],
        entering: maps[i]["entering"] == 1 ? true : false,
        totalHours: maps[i]["totalHours"],
        empCode: maps[i]["empCode"],
      );
    });
  }

  Future<void> updateEmpsLocsView(Emps_Locs_View emp) async {
    final db = _database;
    await db.update('Emps_Locs_Views', emp.toMap(),
        where: 'empCode = ?', whereArgs: [emp.empCode]);
  }

  Future<void> deleteEmpsLocsView(Emps_Locs_View emp) async {
    await _lock.synchronized(() async {
      final db = _database;
      await db.delete('Emps_Locs_Views');
    });
  }

  Future<void> insertAttendings(Attendings attendings) async {
    if (_database.isOpen) {
      await _lock.synchronized(() async {
        await _database
            .insert('Attendings', attendings.toJson())
            .then((value) async {
          var sharedPrefs = await SharedPreferences.getInstance();
          await sharedPrefs.setBool("entering", attendings.entering);
          await sharedPrefs.remove("adding....");
        });
      });
    } else {
      print("db is closed");
    }
  }

//retrieve employees
  Future<List<Attendings>> getAttendings() async {
    return database().then((value) async {
      final List<Map<String, dynamic>> maps =
          await _database.query('Attendings');
      return List.generate(maps.length, (i) {
        return Attendings(
          empKey: maps[i]["empKey"],
          locationKey: maps[i]["locationKey"],
          leaveAfter: maps[i]["leaveAfter"],
          entering: maps[i]["entering"] == 1 ? true : false,
          atdt: DateTime.parse(maps[i]["atdt"]),
        );
      });
    });
  }

//retrieve employees
  Future<List<Attendings>> AttendingsByEmpIdandLocation(String empCode) async {
    final db = _database;
    final List<Map<String, dynamic>> maps =
        await db.query('Attendings', where: "empCode =" + empCode);
    return List.generate(maps.length, (i) {
      return Attendings(
          empKey: maps[i]["empKey"],
          locationKey: maps[i]["locationKey"],
          leaveAfter: maps[i]["leaveAfter"],
          entering: maps[i]["entering"],
          atdt: maps[i]["atdt"]);
    });
  }

  Future<void> updateAttendings(Attendings attendings) async {
    final db = _database;
    await db.update('Attendings', attendings.toJson(),
        where: 'atdt = ?', whereArgs: [attendings.atdt]);
  }

  Future<void> deleteAttendings(Attendings attendings) async {
    await _lock.synchronized(() async {
      final db = _database;
      await db.delete('Attendings',
          where: 'atdt = ?', whereArgs: [attendings.atdt.toIso8601String()]);
    });
  }

  //insert locations
  Future<void> insertlocations(Locations loc) async {
    await _database.insert(
      'Locations',
      loc.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

//retrieve locations
  Future<List<Locations>> locations() async {
    final List<Map<String, Object>> maps = await _database.query('Locations');

    return List.generate(maps.length, (i) {
      return Locations(
        Id: maps[i]['Id'] as int,
        latitude: maps[i]['latitude'] as double,
        lngtude: maps[i]['lngtude'] as double,
        address: maps[i]['address'] as String,
        area: maps[i]['area'] as num,
        isParent: maps[i]['isParent'] == 1 ? true : false,
        waitingTime: maps[i]['waitingTime'] as num,
      );
    });
  }

//retrieve locations

  Future<void> deleteLocs() async {
    await _lock.synchronized(() async {
      final db = _database;
      await db.delete('Locations');
    });
  }
}

dbHelper db = dbHelper();
