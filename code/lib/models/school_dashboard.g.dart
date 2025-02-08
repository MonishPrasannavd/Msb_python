// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolDashboard _$SchoolDashboardFromJson(Map<String, dynamic> json) =>
    SchoolDashboard(
      studentsCount: (json['students_count'] as num?)?.toInt(),
      submissionsCount: (json['submissions_count'] as num?)?.toInt(),
      submissionsLikes: (json['submissions_likes'] as num?)?.toInt(),
      points: (json['points'] as num?)?.toInt(),
      topStudents: (json['top_students'] as List<dynamic>?)
          ?.map((e) => TopStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SchoolDashboardToJson(SchoolDashboard instance) =>
    <String, dynamic>{
      'students_count': instance.studentsCount,
      'submissions_count': instance.submissionsCount,
      'submissions_likes': instance.submissionsLikes,
      'points': instance.points,
      'top_students': instance.topStudents,
    };

TopStudent _$TopStudentFromJson(Map<String, dynamic> json) => TopStudent(
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
      city: json['city'] as String?,
      rank: (json['rank'] as num?)?.toInt(),
      schoolId: (json['school_id'] as num?)?.toInt(),
      likes: (json['likes'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      createdBy: json['created_by'],
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TopStudentToJson(TopStudent instance) =>
    <String, dynamic>{
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
      'user': instance.user,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      email: json['email'] as String?,
      image: json['image'],
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      roleId: (json['role_id'] as num?)?.toInt(),
      imageUrl: json['image_url'],
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'email': instance.email,
      'image': instance.image,
      'id': instance.id,
      'name': instance.name,
      'role_id': instance.roleId,
      'image_url': instance.imageUrl,
    };
