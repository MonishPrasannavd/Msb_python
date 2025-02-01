import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:msb_app/models/competition_data.dart';
import 'package:msb_app/models/competitions.dart';
import 'package:msb_app/models/currentstudent.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/utils/api.dart';

class UserDataProvider with ChangeNotifier {
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
      CurrentStudent user = CurrentStudent.fromJson(encodedString);

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

  Future<Map<String, dynamic>> getCompetitonsCategories(accessToken) async {
    // CurrentStudent user = UserProvider().user;
    Map<String, Object> result;
    notifyListeners();
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.GET_CATEGORIES);
    Response response = await get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> encodedString =
          jsonDecode(response.body.toString());
      List<CompetitionsCategories> categories =
          List.castFrom(encodedString['data'])
              .map((e) => CompetitionsCategories.fromJson(e))
              .toList();
      notifyListeners();
      result = {
        'status': true,
        'message': 'Success',
        'competitions': categories
      };
    } else {
      notifyListeners();
      result = {'status': true, 'message': 'Failed', 'competitions': 'null'};
    }
    return result;
  }
}
