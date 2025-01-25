// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolUser _$SchoolUserFromJson(Map<String, dynamic> json) => SchoolUser(
      id: json['id'] as String?,
      schoolId: json['schoolId'] as String?,
      schoolName: json['schoolName'] as String?,
      averagePoints: (json['averagePoints'] as num?)?.toDouble() ?? 0.0,
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
      totalSubmissions: (json['totalSubmissions'] as num?)?.toInt() ?? 0,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$SchoolUserToJson(SchoolUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schoolName': instance.schoolName,
      'schoolId': instance.schoolId,
      'averagePoints': instance.averagePoints,
      'studentCount': instance.studentCount,
      'totalSubmissions': instance.totalSubmissions,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
