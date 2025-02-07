import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:msb_app/models/school.dart';
import 'package:msb_app/models/school_dashboard.dart';
import 'package:msb_app/models/school_rank.dart';
import 'package:msb_app/models/student.dart';
import 'package:msb_app/utils/api.dart';

class SchoolApiProvider extends ChangeNotifier {

  Future<Map<String, dynamic>> getSchoolDashboard(int schoolId) async {
    Map<String, dynamic> result;
    notifyListeners();

    final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.GET_SCHOOL_DASHBOARD}/${schoolId.toString()}");
    try {
      var response = await get(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        // var user = MsbUser.fromJson(encodedString);
        var dashboard = SchoolDashboard.fromJson(encodedString['dashboard']);
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful', 'dashboard': dashboard};
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

  Future<Map<String, dynamic>> getTopSchools() async {
    Map<String, dynamic> result;
    notifyListeners();

    final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.GET_TOP_SCHOOLS}");
    try {
      var response = await get(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        // var user = MsbUser.fromJson(encodedString);
        var topSchools = List.castFrom(encodedString).map((e) => SchoolRank.fromJson(e)).toList();
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful', 'topSchools': topSchools};
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

  Future<Map<String, dynamic>> getStudentsBySchoolId(int schoolId, {int? page = 1, limit = 10}) async {
    Map<String, dynamic> result;
    notifyListeners();

    final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.GET_STUDENT_BY_SCHOOL_ID}/$schoolId?page=$page&limit=$limit");
    try {
      var response = await get(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        // var user = MsbUser.fromJson(encodedString);
        var students = List.castFrom(encodedString['users']).map((e) => Student.fromJson(e)).toList();
        var page = encodedString['page'];
        var limit = encodedString['limit'];
        var total = encodedString['total'];
        var totalPages = encodedString['total_pages'];
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful', 'students': students, 'page': page, 'limit': limit, 'total': total, 'totalPages': totalPages};
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


  Future<Map<String, dynamic>> getAllSchools() async {
    Map<String, dynamic> result;
    notifyListeners();

    final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.GET_ALL_SCHOOLS}");
    try {
      var response = await get(uri, headers: AppUrl.headers);
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        // var user = MsbUser.fromJson(encodedString);
        var schools = List.castFrom(encodedString).map((e) => School.fromJson(e)).toList();
        notifyListeners();
        // result = {'status': true, 'message': 'Successful', 'user': user};
        result = {'status': true, 'message': 'Successful', 'schools': schools};
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
}
