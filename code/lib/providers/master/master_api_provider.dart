import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:msb_app/models/country.dart';
import 'package:msb_app/models/grade.dart';
import 'package:msb_app/models/school.dart';
import 'package:msb_app/models/msb_state.dart';
import 'package:msb_app/utils/api.dart';

class MasterApiProvider extends ChangeNotifier {
  Future<Map<String, dynamic>> getMasterData() async {
    Map<String, dynamic> result;

    notifyListeners();

    final uri = Uri.parse(AppUrl.BASE_URL + AppUrl.GET_MASTERDATA);
    Response response = await post(
      uri,
      headers: AppUrl.headers,
    );

    if (response.statusCode == 200) {
      var encodedString = jsonDecode(response.body.toString());

      List<Grade> grades = List.castFrom(encodedString['grades']).map((e) => Grade.fromJson(e)).toList();
      List<Country> countries = List.castFrom(encodedString['countries']).map((e) => Country.fromJson(e)).toList();
      List<MsbState> states = List.castFrom(encodedString['states']).map((e) => MsbState.fromJson(e)).toList();
      List<School> schools = List.castFrom(encodedString['schools']).map((e) => School.fromJson(e)).toList();

      notifyListeners();
      result = {'status': true, 'message': 'Successful', 'grades': grades, 'countries': countries, 'states': states, 'schools': schools};
    } else {
      final Map<String, dynamic> responseData = json.decode(response.body);
      var message = responseData['detail'];
      notifyListeners();
      result = {'status': false, 'message': message};
    }
    return result;
  }
}
