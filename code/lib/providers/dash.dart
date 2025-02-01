import 'package:flutter/cupertino.dart';
import 'package:msb_app/models/dashboard.dart';

class Dash with ChangeNotifier {

  List<TopScoreStudents> topStudentList = [];
  List<FutureCategories> futureCateList = [];
  List<Subcategories> subCateList = [];
  DashboardResponse dashboardResponse = DashboardResponse(
    totalSchools: 0,
    totalStudent: 0,

    futureCategories: [FutureCategories(
      name: '',
      id: 0,
      icon: '',
      iconUrl: '',
      isFuture: 0,
      subcategories: [Subcategories(
        id: 0,
        icon: '',
        name: '',
        categoryId: 0
      )],
      type: 0,
    )],

    topScoreStudents: [TopScoreStudents(
      id: 0,
      dob: '',
      city: '',
      countryId: 0,
      createdAt: '',
      createdBy: '',
      gradeId: 0,
      likes: 0,
      points: 0,
      schoolId: 0,
      score: 0,
      stateId: 0,
      updatedAt: '',
      user: User(
        name: '',
        id: 0,
        image: '',
        email: '',
        imageUrl: '',
        roleId: 0
      ),
      userId: 0,
    )]
  );

  /*TopScoreStudents topScoreStudents = TopScoreStudents(
    id: 0,
    dob: '',
    city: '',
    countryId: 0,
    createdAt: '',
    createdBy: '',
    gradeId: 0,
    likes: 0,
    points: 0,
    schoolId: 0,
    score: 0,
    stateId: 0,
    updatedAt: '',
    user: '',
    userId: 0,
  );

  FutureCategories futureCategories = FutureCategories(
    name: '',
    id: 0,
    icon: '',
    iconUrl: '',
    isFuture: 0,
    *//*subcategories: Subcategories(
        id: 0,
        icon: '',
        name: '',
        categoryId: 0
    ) as List<Subcategories>,*//*
    subcategories: [],
    type: 0,
  );

  Subcategories subcategories = Subcategories(
      id: 0,
      icon: '',
      name: '',
      categoryId: 0
  );*/

  DashboardResponse get dbResponse => dashboardResponse;
  void setDash(DashboardResponse dbRes) {
    dashboardResponse = dbRes;
    notifyListeners();
  }

  List<TopScoreStudents>? get tsStudents => dashboardResponse.topScoreStudents;
  void students(List<TopScoreStudents> value) {
    topStudentList = value;
    notifyListeners();
  }

  List<FutureCategories>? get ftCategories => dashboardResponse.futureCategories;
  void category(List<FutureCategories> value) {
    futureCateList = value;
    notifyListeners();
  }

  List<Subcategories> get subCate => dashboardResponse.futureCategories?.expand((category) {
    return (category.subcategories ?? []).whereType<Subcategories>().toList();}).toList() ?? [];
  void sub(List<Subcategories> value) {
    subCateList = value;
    notifyListeners();
  }

}