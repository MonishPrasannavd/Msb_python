import 'package:flutter/material.dart';
import 'package:msb_app/models/msb_country.dart';
import 'package:msb_app/models/grade.dart';
import 'package:msb_app/models/msb_state.dart';
import 'package:msb_app/models/school.dart';

class MasterProvider extends ChangeNotifier {
  List<MsbCountry> _countries = [];
  List<MsbState> _states = [];
  List<School> _schools = [];
  List<Grade> _grades = [];

  List<MsbCountry> get countries => _countries;

  set countries(List<MsbCountry> value) {
    _countries = value;
    notifyListeners();
  }

  List<MsbState> get states => _states;

  set states(List<MsbState> value) {
    _states = value;
    notifyListeners();
  }

  List<School> get schools => _schools;

  set schools(List<School> value) {
    _schools = value;
    notifyListeners();
  }

  List<Grade> get grades => _grades;

  set grades(List<Grade> value) {
    _grades = value;
    notifyListeners();
  }
}
