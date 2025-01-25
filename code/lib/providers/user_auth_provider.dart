import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:msb_app/models/msbuser.dart';
import 'package:msb_app/utils/api.dart';

class UserAuthProvider with ChangeNotifier {
  Future<Map<String, dynamic>> login(String email, String password) async {
    Map<String, dynamic> result;

    Map<String, dynamic> loginData = {
      'email': email,
      'password': password,
    };
    notifyListeners();

    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.AUTHENTICATION);
    Response response = await post(
      uri,
      headers: headers,
      body: jsonEncode(loginData),
    );

    if (response.statusCode == 200) {
      var encodedString = jsonDecode(response.body.toString());
      //Map<String, dynamic> jsonMap = jsonDecode(encodedString);
      MsbUser user = MsbUser.fromJson(encodedString);

      notifyListeners();

      result = {'status': true, 'message': 'Successful', 'user': user};
    } else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      var message = responseData['detail'];
      notifyListeners();
      result = {'status': false, 'message': message, 'user': null};
    }
    return result;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String gradeId, String countryId,
      String stateId, String city, String? schoolId, String? schoolName, String dob) async {
    Map<String, dynamic> result;

    Map<String, dynamic> registerData = {
      "name": name,
      "email": email,
      "password": password,
      "grade_id": int.parse(gradeId),
      "country_id": int.parse(countryId),
      "state_id": int.parse(stateId),
      "city": city,
      "school_id": schoolId != null ? int.parse(schoolId) : null,
      "school_name": schoolName,
      "dob": dob
    };

    try {
      final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.SIGNUP);
      Response response = await post(
        uri,
        headers: AppUrl.headers,
        body: jsonEncode(registerData),
      );

      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        MsbUser user = MsbUser.fromJson(encodedString);
        notifyListeners();
        result = {'status': true, 'message': 'Successful', 'user': user};
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        var message = responseData['detail'];
        notifyListeners();
        result = {'status': false, 'message': message, 'user': null};
      }
    } catch (e) {
      notifyListeners();
      result = {'status': false, 'message': e.toString()};
    }

    return result;
  }
}
