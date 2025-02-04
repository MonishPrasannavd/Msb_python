import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:msb_app/models/competitions.dart';
import 'package:msb_app/utils/api.dart';

class CategoryApiProvider extends ChangeNotifier {
  Future<Map<String, dynamic>> getCategories(accessToken) async {
    // CurrentStudent user = UserProvider().user;
    Map<String, Object> result;
    notifyListeners();

    final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.GET_CATEGORIES);
    Response response = await get(
      uri,
      headers: AppUrl.headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> encodedString = jsonDecode(response.body.toString());
      List<CompetitionsCategories> categories =
          List.castFrom(encodedString['data']).map((e) => CompetitionsCategories.fromJson(e)).toList();
      notifyListeners();
      result = {'status': true, 'message': 'Success', 'competitions': categories};
    } else {
      notifyListeners();
      result = {'status': true, 'message': 'Failed', 'competitions': 'null'};
    }
    return result;
  }

  Future<Map<String, dynamic>> getSubcategories() async {
    Map<String, Object> result;
    notifyListeners();
    final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.GET_SUBCATEGORIES);
    Response response = await get(
      uri,
      headers: AppUrl.headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> encodedString = jsonDecode(response.body.toString());
      List<CompetitionsCategories> categories =
          List.castFrom(encodedString['data']).map((e) => CompetitionsCategories.fromJson(e)).toList();
      notifyListeners();
      result = {'status': true, 'message': 'Success', 'competitions': categories};
    } else {
      notifyListeners();
      result = {'status': true, 'message': 'Failed', 'competitions': 'null'};
    }
    return result;
  }
}
