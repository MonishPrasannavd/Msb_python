// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      id: (json['id'] as num?)?.toInt(),
      score: (json['score'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      points: (json['points'] as num?)?.toInt(),
      gradeId: (json['grade_id'] as num?)?.toInt(),
      likes: (json['likes'] as num?)?.toInt(),
      schoolId: (json['school_id'] as num?)?.toInt(),
      createdBy: json['created_by'],
      countryId: (json['country_id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      stateId: (json['state_id'] as num?)?.toInt(),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      city: json['city'] as String?,
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      user: json['user'] == null
          ? null
          : StudentUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'id': instance.id,
      'score': instance.score,
      'user_id': instance.userId,
      'points': instance.points,
      'grade_id': instance.gradeId,
      'likes': instance.likes,
      'school_id': instance.schoolId,
      'created_by': instance.createdBy,
      'country_id': instance.countryId,
      'created_at': instance.createdAt?.toIso8601String(),
      'state_id': instance.stateId,
      'updated_at': instance.updatedAt?.toIso8601String(),
      'city': instance.city,
      'dob': instance.dob?.toIso8601String(),
      'user': instance.user,
    };

StudentUser _$StudentUserFromJson(Map<String, dynamic> json) => StudentUser(
      name: json['name'] as String?,
      email: json['email'] as String?,
      image: json['image'],
      roleId: (json['role_id'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      role: json['role'] == null
          ? null
          : StudentRole.fromJson(json['role'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentUserToJson(StudentUser instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'image': instance.image,
      'role_id': instance.roleId,
      'id': instance.id,
      'role': instance.role,
    };

StudentRole _$StudentRoleFromJson(Map<String, dynamic> json) => StudentRole(
      name: json['name'] as String?,
      createdBy: (json['created_by'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StudentRoleToJson(StudentRole instance) =>
    <String, dynamic>{
      'name': instance.name,
      'created_by': instance.createdBy,
      'id': instance.id,
    };
