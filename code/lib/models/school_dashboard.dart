import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'school_dashboard.g.dart';

@JsonSerializable()
class SchoolDashboard {
  @JsonKey(name: "students_count")
  int? studentsCount;
  @JsonKey(name: "submissions_count")
  int? submissionsCount;
  @JsonKey(name: "submissions_likes")
  int? submissionsLikes;
  @JsonKey(name: "top_submissions_likes")
  int? topSubmissionsLikes;
  @JsonKey(name: "top_students")
  int? topStudents;
  @JsonKey(name: "school_rank")
  int? schoolRank;

  SchoolDashboard({
    this.studentsCount,
    this.submissionsCount,
    this.submissionsLikes,
    this.topSubmissionsLikes,
    this.topStudents,
    this.schoolRank,
  });

  SchoolDashboard copyWith({
    int? studentsCount,
    int? submissionsCount,
    int? submissionsLikes,
    int? topSubmissionsLikes,
    int? topStudents,
    int? schoolRank,
  }) =>
      SchoolDashboard(
        studentsCount: studentsCount ?? this.studentsCount,
        submissionsCount: submissionsCount ?? this.submissionsCount,
        submissionsLikes: submissionsLikes ?? this.submissionsLikes,
        topSubmissionsLikes: topSubmissionsLikes ?? this.topSubmissionsLikes,
        topStudents: topStudents ?? this.topStudents,
        schoolRank: schoolRank ?? this.schoolRank,
      );

  factory SchoolDashboard.fromJson(Map<String, dynamic> json) => _$SchoolDashboardFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolDashboardToJson(this);
}
