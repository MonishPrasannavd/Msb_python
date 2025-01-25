import 'package:flutter/foundation.dart';
import 'package:msb_app/models/grade.dart';
import 'package:msb_app/models/msb_country.dart';
import 'package:msb_app/models/msb_state.dart';
import 'package:msb_app/models/school.dart';

class MsbUser {
  final User? user;
  final Student student;
  final String accessToken;
  final String tokenType;

  MsbUser({
    required this.user,
    required this.student,
    required this.accessToken,
    required this.tokenType,
  });

  factory MsbUser.fromJson(Map<String, dynamic> json) {
    User? getUserFromJson(Map<String, dynamic> json) {
      if (json['user'] != null) {
        return User.fromJson(json['user']);
      } else if (json['student'] != null && json['student']['user'] != null) {
        return User.fromJson(json['student']['user']);
      } else {
        return null;
      }
    }

    return MsbUser(
      user: getUserFromJson(json),
      student: Student.fromJson(json['student']),
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
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
  final String? roleName;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.points,
    required this.likes,
    required this.score,
    this.profileUrl,
    required this.roleId,
    this.roleName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      points: json['points'] ?? 0,
      likes: json['likes'] ?? 0,
      score: json['score'] ?? 0,
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
  final MsbCountry? country;
  final Grade? grade;
  final School? school;
  final MsbState? state;

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
      country: json['country'] != null ? MsbCountry.fromJson(json['country']) : null,
      grade: json['grade'] != null ? Grade.fromJson(json['grade']) : null,
      school: json['school'] != null ? School.fromJson(json['school']) : null,
      state: json['state'] != null ? MsbState.fromJson(json['state']) : null,
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
      'country': country?.toJson(),
      'grade': grade?.toJson(),
      'school': school?.toJson(),
      'state': state?.toJson(),
    };
  }
}


