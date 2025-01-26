import 'package:json_annotation/json_annotation.dart';
//part 'currentstudent.g.dart';

@JsonSerializable(explicitToJson: true)
class CurrentStudent {
  final User user;
  final Student student;
  final String accessToken;
  final String tokenType;

  CurrentStudent({
    required this.user,
    required this.student,
    required this.accessToken,
    required this.tokenType,
  });

  factory CurrentStudent.fromJson(Map<String, dynamic> json) {
    return CurrentStudent(
      user: User.fromJson(json['user']),
      student: Student.fromJson(json['student']),
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'student': student.toJson(),
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final int points;
  final int likes;
  final int score;
  final String? profileUrl;
  final int roleId;
  final String roleName;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.points,
    required this.likes,
    required this.score,
    this.profileUrl,
    required this.roleId,
    required this.roleName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      points: json['points'],
      likes: json['likes'],
      score: json['score'],
      profileUrl: json['profile_url'],
      roleId: json['role_id'],
      roleName: json['role_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'points': points,
      'likes': likes,
      'score': score,
      'profile_url': profileUrl,
      'role_id': roleId,
      'role_name': roleName,
    };
  }
}

class Student {
  final int id;
  final int gradeId;
  final int countryId;
  final String dob;
  final int points;
  final dynamic createdBy;
  final String updatedAt;
  final int userId;
  final int schoolId;
  final int stateId;
  final int score;
  final int likes;
  final String createdAt;
  final Country country;
  final Grade grade;
  final School school;
  final State state;

  Student({
    required this.id,
    required this.gradeId,
    required this.countryId,
    required this.dob,
    required this.points,
    this.createdBy,
    required this.updatedAt,
    required this.userId,
    required this.schoolId,
    required this.stateId,
    required this.score,
    required this.likes,
    required this.createdAt,
    required this.country,
    required this.grade,
    required this.school,
    required this.state,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      gradeId: json['grade_id'],
      countryId: json['country_id'],
      dob: json['dob'],
      points: json['points'],
      createdBy: json['created_by'],
      updatedAt: json['updated_at'],
      userId: json['user_id'],
      schoolId: json['school_id'],
      stateId: json['state_id'],
      score: json['score'],
      likes: json['likes'],
      createdAt: json['created_at'],
      country: Country.fromJson(json['country']),
      grade: Grade.fromJson(json['grade']),
      school: School.fromJson(json['school']),
      state: State.fromJson(json['state']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grade_id': gradeId,
      'country_id': countryId,
      'dob': dob,
      'points': points,
      'created_by': createdBy,
      'updated_at': updatedAt,
      'user_id': userId,
      'school_id': schoolId,
      'state_id': stateId,
      'score': score,
      'likes': likes,
      'created_at': createdAt,
      'country': country.toJson(),
      'grade': grade.toJson(),
      'school': school.toJson(),
      'state': state.toJson(),
    };
  }
}

class Country {
  final int id;
  final String name;
  final dynamic createdBy;

  Country({
    required this.id,
    required this.name,
    this.createdBy,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
    };
  }
}

class Grade {
  final int id;
  final String name;
  final dynamic createdBy;

  Grade({
    required this.id,
    required this.name,
    this.createdBy,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'],
      name: json['name'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
    };
  }
}

class School {
  final int id;
  final String name;
  final int createdBy;

  School({
    required this.id,
    required this.name,
    required this.createdBy,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'],
      name: json['name'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_by': createdBy,
    };
  }
}

class State {
  final int id;
  final String name;
  final int countryId;
  final dynamic createdBy;

  State({
    required this.id,
    required this.name,
    required this.countryId,
    this.createdBy,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'],
      name: json['name'],
      countryId: json['country_id'],
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_id': countryId,
      'created_by': createdBy,
    };
  }
}