import 'package:json_annotation/json_annotation.dart';

part 'school_dashboard.g.dart';

@JsonSerializable()
class SchoolDashboard {
  @JsonKey(name: "students_count")
  int? studentsCount;
  @JsonKey(name: "submissions_count")
  int? submissionsCount;
  @JsonKey(name: "submissions_likes")
  int? submissionsLikes;
  @JsonKey(name: "points")
  int? points;
  @JsonKey(name: "top_students")
  List<TopStudent>? topStudents;

  SchoolDashboard({
    this.studentsCount,
    this.submissionsCount,
    this.submissionsLikes,
    this.points,
    this.topStudents,
  });

  SchoolDashboard copyWith({
    int? studentsCount,
    int? submissionsCount,
    int? submissionsLikes,
    int? points,
    List<TopStudent>? topStudents,
  }) =>
      SchoolDashboard(
        studentsCount: studentsCount ?? this.studentsCount,
        submissionsCount: submissionsCount ?? this.submissionsCount,
        submissionsLikes: submissionsLikes ?? this.submissionsLikes,
        points: points ?? this.points,
        topStudents: topStudents ?? this.topStudents,
      );

  factory SchoolDashboard.fromJson(Map<String, dynamic> json) =>
      _$SchoolDashboardFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolDashboardToJson(this);
}

@JsonSerializable()
class TopStudent {
  @JsonKey(name: "grade_id")
  int? gradeId;
  @JsonKey(name: "created_at")
  DateTime? createdAt;
  @JsonKey(name: "dob")
  DateTime? dob;
  @JsonKey(name: "updated_at")
  DateTime? updatedAt;
  @JsonKey(name: "score")
  int? score;
  @JsonKey(name: "user_id")
  int? userId;
  @JsonKey(name: "state_id")
  int? stateId;
  @JsonKey(name: "points")
  int? points;
  @JsonKey(name: "country_id")
  int? countryId;
  @JsonKey(name: "city")
  String? city;
  @JsonKey(name: "rank")
  int? rank;
  @JsonKey(name: "school_id")
  int? schoolId;
  @JsonKey(name: "likes")
  int? likes;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "created_by")
  dynamic createdBy;
  @JsonKey(name: "user")
  User? user;

  TopStudent({
    this.gradeId,
    this.createdAt,
    this.dob,
    this.updatedAt,
    this.score,
    this.userId,
    this.stateId,
    this.points,
    this.countryId,
    this.city,
    this.rank,
    this.schoolId,
    this.likes,
    this.id,
    this.createdBy,
    this.user,
  });

  TopStudent copyWith({
    int? gradeId,
    DateTime? createdAt,
    DateTime? dob,
    DateTime? updatedAt,
    int? score,
    int? userId,
    int? stateId,
    int? points,
    int? countryId,
    String? city,
    int? rank,
    int? schoolId,
    int? likes,
    int? id,
    dynamic createdBy,
    User? user,
  }) =>
      TopStudent(
        gradeId: gradeId ?? this.gradeId,
        createdAt: createdAt ?? this.createdAt,
        dob: dob ?? this.dob,
        updatedAt: updatedAt ?? this.updatedAt,
        score: score ?? this.score,
        userId: userId ?? this.userId,
        stateId: stateId ?? this.stateId,
        points: points ?? this.points,
        countryId: countryId ?? this.countryId,
        city: city ?? this.city,
        rank: rank ?? this.rank,
        schoolId: schoolId ?? this.schoolId,
        likes: likes ?? this.likes,
        id: id ?? this.id,
        createdBy: createdBy ?? this.createdBy,
        user: user ?? this.user,
      );

  factory TopStudent.fromJson(Map<String, dynamic> json) =>
      _$TopStudentFromJson(json);

  Map<String, dynamic> toJson() => _$TopStudentToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: "email")
  String? email;
  @JsonKey(name: "image")
  dynamic image;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "role_id")
  int? roleId;
  @JsonKey(name: "image_url")
  dynamic imageUrl;

  User({
    this.email,
    this.image,
    this.id,
    this.name,
    this.roleId,
    this.imageUrl,
  });

  User copyWith({
    String? email,
    dynamic image,
    int? id,
    String? name,
    int? roleId,
    dynamic imageUrl,
  }) =>
      User(
        email: email ?? this.email,
        image: image ?? this.image,
        id: id ?? this.id,
        name: name ?? this.name,
        roleId: roleId ?? this.roleId,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
