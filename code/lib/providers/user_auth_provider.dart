import 'dart:async';
import 'dart:convert';
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
}
