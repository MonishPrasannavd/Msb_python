import 'package:flutter/foundation.dart';
import 'package:msb_app/models/currentstudent.dart';

class UserProvider with ChangeNotifier {
  CurrentStudent _user = CurrentStudent(
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
      country: Country(
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
      state: State(
        id: 0,
        name: '',
        countryId: 0,
        createdBy: null,
      ),
    ),
    accessToken: '',
    tokenType: '',
  );

  CurrentStudent get user => _user;

  void setUser(CurrentStudent user) {
    _user = user;
    notifyListeners();
  }
}
