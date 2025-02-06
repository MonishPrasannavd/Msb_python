// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currentstudent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentStudent _$CurrentStudentFromJson(Map<String, dynamic> json) =>
    CurrentStudent(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      student: Student.fromJson(json['student'] as Map<String, dynamic>),
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
    );

Map<String, dynamic> _$CurrentStudentToJson(CurrentStudent instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'student': instance.student.toJson(),
      'accessToken': instance.accessToken,
      'tokenType': instance.tokenType,
    };
