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
      topSubmissionsLikes: (json['top_submissions_likes'] as num?)?.toInt(),
      topStudents: (json['top_students'] as num?)?.toInt(),
      schoolRank: (json['school_rank'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SchoolDashboardToJson(SchoolDashboard instance) =>
    <String, dynamic>{
      'students_count': instance.studentsCount,
      'submissions_count': instance.submissionsCount,
      'submissions_likes': instance.submissionsLikes,
      'top_submissions_likes': instance.topSubmissionsLikes,
      'top_students': instance.topStudents,
      'school_rank': instance.schoolRank,
    };
