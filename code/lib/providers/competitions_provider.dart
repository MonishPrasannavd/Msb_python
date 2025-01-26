import 'package:flutter/material.dart';
import 'package:msb_app/models/competitions.dart';
import 'package:msb_app/providers/user_data_provider.dart';
import 'package:msb_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/competition_data.dart';

class CompetitionsProvider with ChangeNotifier {
  List<CompetitionsCategories> _compititions = [];
  set setCompetitions(List<CompetitionsCategories> value) {
    _compititions = value;
    notifyListeners();
  }

  List<CompetitionsCategories> get compititions => _compititions;
  bool loading = false;
  UserDataProvider userProvider = UserDataProvider();
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
