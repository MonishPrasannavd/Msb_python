import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:msb_app/models/dashboard.dart';
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

      AppUrl.addHeader('Authorization', 'Bearer ${user.accessToken}');

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
      "school_id": (schoolId != null && schoolId.isNotEmpty) ? int.tryParse(schoolId) : null,
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

  Future<Map<String, dynamic>> getUserMe(MsbUser existingUser) async {
    Map<String, dynamic> result;

    try {
      final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.GET_USERME);
      Response response = await get(
        uri,
        headers: AppUrl.headers,
      );
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        MsbUser user = MsbUser.fromJson(encodedString, existingUser: existingUser);
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

  Future<Map<String, dynamic>> logout() async {
    Map<String, dynamic> result;

    try {
      final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.LOGOUT);
      Response response = await get(
        uri,
        headers: AppUrl.headers,
      );
      if (response.statusCode == 200) {
        notifyListeners();
        result = {'status': true, 'message': 'Successful'};
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        var message = responseData['detail'];
        notifyListeners();
        result = {'status': false, 'message': message};
      }
    } catch (e) {
      notifyListeners();
      result = {'status': false, 'message': e.toString()};
    }

    return result;
  }

  Future<Map<String, dynamic>> getUser(String id) async {
    Map<String, dynamic> result;

    try {
      final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.GET_USER}?id=$id");
      Response response = await get(
        uri,
        headers: AppUrl.headers,
      );
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        notifyListeners();
        // TODO : implement parsing json
        result = {'status': true, 'message': 'Successful', 'user': encodedString};
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        var message = responseData['detail'];
        notifyListeners();
        result = {'status': false, 'message': message};
      }
    } catch (e) {
      notifyListeners();
      result = {'status': false, 'message': e.toString()};
    }

    return result;
  }

  Future<Map<String, dynamic>> updateProfile(String name, int gradeId, {File? profileImage}) async {
    Map<String, dynamic> result;

    try {
      // Prepare the multipart request
      var uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.UPDATE_USER}");
      var request = MultipartRequest("PUT", uri);

      // Add headers
      request.headers.addAll(AppUrl.headers);

      // Add fields
      request.fields['name'] = name;
      request.fields['grade_id'] = gradeId.toString();

      // Add file if it exists
      if (profileImage != null && await profileImage.exists()) {
        request.files.add(
          await MultipartFile.fromPath(
            'profile_image', // Field name for the image
            profileImage.path,
            contentType: MediaType('image', 'jpeg'), // Adjust the content type if needed
          ),
        );
      } else {
        // request.fields['profile_image'] = null; // Explicitly set null
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        // var user = MsbUser.fromJson(encodedString);
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful'};
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        var message = responseData['detail'];
        notifyListeners();
        result = {'status': false, 'message': message};
      }
    } catch (e) {
      notifyListeners();
      result = {'status': false, 'message': e.toString()};
    }

    return result;
  }

  Future<Map<String, dynamic>> getCompetitonsCategories(accessToken) async {
    Map<String, Object> result;
    notifyListeners();
    final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.GET_CATEGORIES);
    Response response = await get(
      uri,
      headers: AppUrl.headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> encodedString = jsonDecode(response.body.toString());
      List<FutureCategories> categories =
          List.castFrom(encodedString['data']).map((e) => FutureCategories.fromJson(e)).toList();
      notifyListeners();
      result = {'status': true, 'message': 'Success', 'competitions': categories};
    } else {
      notifyListeners();
      result = {'status': true, 'message': 'Failed', 'competitions': 'null'};
    }
    return result;
  }
}
