import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:msb_app/models/competitions.dart';
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompetitionsProvider with ChangeNotifier {
  List<FutureCategories> _compititions = [];

  set setCompetitions(List<FutureCategories> value) {
    _compititions = value;
    notifyListeners();
  }

  List<FutureCategories> get compititions => _compititions;
  bool loading = false;

  UserAuthProvider userProvider = UserAuthProvider();

  Future<Map<String, dynamic>> getCompetitionsData() async {
    Map<String, dynamic> result;
    notifyListeners();

    final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.GET_CATEGORIES);

    try {
      var response = await get(uri, headers: AppUrl.headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> encodedString = jsonDecode(response.body.toString());
        List<FutureCategories> categories =
            List.castFrom(encodedString['data']).map((e) => FutureCategories.fromJson(e)).toList();
        notifyListeners();
        result = {'status': true, 'message': 'Success', 'competitions': categories};
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
