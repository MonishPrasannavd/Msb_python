import 'package:json_annotation/json_annotation.dart';

part 'user_single.g.dart';

@JsonSerializable()
class UserSingle {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "email")
  String? email;
  @JsonKey(name: "role_id")
  int? roleId;
  @JsonKey(name: "image_url")
  String? imageUrl;
  @JsonKey(name: "student")
  Student? student;
  @JsonKey(name: "role")
  Role? role;
  @JsonKey(name: "submissions_count")
  int? submissionsCount;
  @JsonKey(name: "comments_count")
  int? commentsCount;
  @JsonKey(name: "likes_count")
  int? likesCount;

  UserSingle({
    this.id,
    this.name,
    this.email,
    this.roleId,
    this.imageUrl,
    this.student,
    this.role,
    this.submissionsCount,
    this.commentsCount,
    this.likesCount,
  });

  UserSingle copyWith({
    int? id,
    String? name,
    String? email,
    int? roleId,
    String? imageUrl,
    Student? student,
    Role? role,
    int? submissionsCount,
    int? commentsCount,
    int? likesCount,
  }) =>
      UserSingle(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        roleId: roleId ?? this.roleId,
        imageUrl: imageUrl ?? this.imageUrl,
        student: student ?? this.student,
        role: role ?? this.role,
        submissionsCount: submissionsCount ?? this.submissionsCount,
        commentsCount: commentsCount ?? this.commentsCount,
        likesCount: likesCount ?? this.likesCount,
      );

  factory UserSingle.fromJson(Map<String, dynamic> json) =>
      _$UserSingleFromJson(json);

  Map<String, dynamic> toJson() => _$UserSingleToJson(this);
}

@JsonSerializable()
class Role {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "created_by")
  int? createdBy;
  @JsonKey(name: "points")
  double? points;
  @JsonKey(name: "country_id")
  int? countryId;

  Role({
    this.name,
    this.id,
    this.createdBy,
    this.points,
    this.countryId,
  });

  Role copyWith({
    String? name,
    int? id,
    int? createdBy,
    double? points,
    int? countryId,
  }) =>
      Role(
        name: name ?? this.name,
        id: id ?? this.id,
        createdBy: createdBy ?? this.createdBy,
        points: points ?? this.points,
        countryId: countryId ?? this.countryId,
      );

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}

@JsonSerializable()
class Student {
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
  dynamic city;
  @JsonKey(name: "rank")
  dynamic rank;
  @JsonKey(name: "school_id")
  int? schoolId;
  @JsonKey(name: "likes")
  int? likes;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "created_by")
  dynamic createdBy;
  @JsonKey(name: "school")
  Role? school;
  @JsonKey(name: "state")
  Role? state;
  @JsonKey(name: "country")
  Role? country;
  @JsonKey(name: "grade")
  Role? grade;

  Student({
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
    this.school,
    this.state,
    this.country,
    this.grade,
  });

  Student copyWith({
    int? gradeId,
    DateTime? createdAt,
    DateTime? dob,
    DateTime? updatedAt,
    int? score,
    int? userId,
    int? stateId,
    int? points,
    int? countryId,
    dynamic city,
    dynamic rank,
    int? schoolId,
    int? likes,
    int? id,
    dynamic createdBy,
    Role? school,
    Role? state,
    Role? country,
    Role? grade,
  }) =>
      Student(
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
        school: school ?? this.school,
        state: state ?? this.state,
        country: country ?? this.country,
        grade: grade ?? this.grade,
      );

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
