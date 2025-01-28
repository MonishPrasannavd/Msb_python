import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:msb_app/models/dashboard.dart';
import 'package:msb_app/utils/api.dart';

class StudentDashboardProvider with ChangeNotifier {
  List<FutureCategories>? dashboardCategoryList ;
  DashboardResponse? dashboardResponseData;

  Future<Map<String, dynamic>> getStudentDashboard() async {
    Map<String, dynamic> result;

    try {
      final uri = Uri.parse("${AppUrl.BASE_URL}${AppUrl.DASHBOARD_USER}");
      Response response = await get(
        uri,
        headers: AppUrl.headers,
      );
      if (response.statusCode == 200) {
        var encodedString = jsonDecode(response.body.toString());
        dashboardResponseData = DashboardResponse.fromJson(encodedString);
        dashboardCategoryList = dashboardResponseData?.futureCategories;
        notifyListeners();

        result = {'status': true, 'message': 'Successful', 'data': dashboardResponseData};
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