// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_single.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSingle _$UserSingleFromJson(Map<String, dynamic> json) => UserSingle(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      roleId: (json['role_id'] as num?)?.toInt(),
      imageUrl: json['image_url'] as String?,
      student: json['student'] == null
          ? null
          : Student.fromJson(json['student'] as Map<String, dynamic>),
      role: json['role'] == null
          ? null
          : Role.fromJson(json['role'] as Map<String, dynamic>),
      submissionsCount: (json['submissions_count'] as num?)?.toInt(),
      commentsCount: (json['comments_count'] as num?)?.toInt(),
      likesCount: (json['likes_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserSingleToJson(UserSingle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role_id': instance.roleId,
      'image_url': instance.imageUrl,
      'student': instance.student,
      'role': instance.role,
      'submissions_count': instance.submissionsCount,
      'comments_count': instance.commentsCount,
      'likes_count': instance.likesCount,
    };

Role _$RoleFromJson(Map<String, dynamic> json) => Role(
      name: json['name'] as String?,
      id: (json['id'] as num?)?.toInt(),
      createdBy: (json['created_by'] as num?)?.toInt(),
      points: (json['points'] as num?)?.toDouble(),
      countryId: (json['country_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RoleToJson(Role instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'created_by': instance.createdBy,
      'points': instance.points,
      'country_id': instance.countryId,
    };

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      gradeId: (json['grade_id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      score: (json['score'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      stateId: (json['state_id'] as num?)?.toInt(),
      points: (json['points'] as num?)?.toInt(),
      countryId: (json['country_id'] as num?)?.toInt(),
      city: json['city'],
      rank: json['rank'],
      schoolId: (json['school_id'] as num?)?.toInt(),
      likes: (json['likes'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      createdBy: json['created_by'],
      school: json['school'] == null
          ? null
          : Role.fromJson(json['school'] as Map<String, dynamic>),
      state: json['state'] == null
          ? null
          : Role.fromJson(json['state'] as Map<String, dynamic>),
      country: json['country'] == null
          ? null
          : Role.fromJson(json['country'] as Map<String, dynamic>),
      grade: json['grade'] == null
          ? null
          : Role.fromJson(json['grade'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'grade_id': instance.gradeId,
      'created_at': instance.createdAt?.toIso8601String(),
      'dob': instance.dob?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'score': instance.score,
      'user_id': instance.userId,
      'state_id': instance.stateId,
      'points': instance.points,
      'country_id': instance.countryId,
      'city': instance.city,
      'rank': instance.rank,
      'school_id': instance.schoolId,
      'likes': instance.likes,
      'id': instance.id,
      'created_by': instance.createdBy,
      'school': instance.school,
      'state': instance.state,
      'country': instance.country,
      'grade': instance.grade,
    };
