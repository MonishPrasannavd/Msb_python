import 'package:flutter/foundation.dart';
import 'package:msb_app/models/grade.dart';
import 'package:msb_app/models/msb_state.dart';
import 'package:msb_app/models/msbuser.dart';
import 'package:msb_app/models/msb_country.dart';
import 'package:msb_app/models/school.dart';

class UserProvider with ChangeNotifier {
  MsbUser _user = MsbUser(
    user: User(
      id: 0,
      name: '',
      email: '',
      points: 0,
      likes: 0,
      score: 0,
      profileUrl: null,
      roleId: 0,
      roleName: '',
    ),
    student: Student(
      id: 0,
      gradeId: 0,
      countryId: 0,
      dob: '',
      points: 0,
      createdBy: null,
      updatedAt: '',
      userId: 0,
      schoolId: 0,
      stateId: 0,
      score: 0,
      likes: 0,
      createdAt: '',
      country: MsbCountry(
        id: 0,
        name: '',
        createdBy: null,
      ),
      grade: Grade(
        id: 0,
        name: '',
        createdBy: null,
      ),
      school: School(
        id: 0,
        name: '',
        createdBy: 0,
      ),
      state: MsbState(
        id: 0,
        name: '',
        countryId: 0,
        createdBy: null,
      ),
    ),
    accessToken: '',
    tokenType: '',
  );

  MsbUser get user => _user;
  MsbCountry? _selectedCountry;
  MsbState? _selectedState;

  // country get set
  MsbCountry? get selectedCountry => _selectedCountry;
  set selectedCountry(MsbCountry? country) {
    _selectedCountry = country;
    notifyListeners();
  }

  // msb state get set
  MsbState? get selectedState => _selectedState;
  set selectedState(MsbState? state) {
    _selectedState = state;
    notifyListeners();
  }

  void setUser(MsbUser user) {
    _user = user;
    notifyListeners();
  }

  void updateUserAndSchool({
    User? updatedUser,
    Student? updatedStudent,
  }) {
    if (updatedUser != null) {
      _user = _user.copyWith(
        user: updatedUser,
      );
    }

    if (updatedStudent  != null) {
      _user = _user.copyWith(
        student: updatedStudent
      );
    }

    notifyListeners();
  }

}
