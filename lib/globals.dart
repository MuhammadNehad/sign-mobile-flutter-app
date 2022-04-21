library signingapp.globals;

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences shared;
Timer t1;
Timer t2;
Timer t3;
Map<String, String> getAuthData(SharedPreferences sharedprefs) {
  var token = sharedprefs.getString("usertoken");
  var code = sharedprefs.getString("myCode");
  var pass = sharedprefs.getString("password");
  var expiryDate = sharedprefs.getString("ExpiryDate");

  return {
    'username': code,
    'password': pass,
    'token': token,
    "ExpiryDate": expiryDate
  };
}
