import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:msb_app/models/competitions.dart';
import 'package:msb_app/providers/user_auth_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:msb_app/utils/api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/competition_data.dart';

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
    //  var user = Provider.of<UserProvider>(context).user;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");
    loading = true;
    final Map<String, dynamic> competitionsData =
        (await userProvider.getCompetitonsCategories(accessToken ?? ""));
    loading = false;

    notifyListeners();
    return competitionsData;
  }
}
