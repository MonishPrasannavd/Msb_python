import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

@JsonSerializable()
class Student {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "score")
  int? score;
  @JsonKey(name: "user_id")
  int? userId;
  @JsonKey(name: "points")
  int? points;
  @JsonKey(name: "grade_id")
  int? gradeId;
  @JsonKey(name: "likes")
  int? likes;
  @JsonKey(name: "school_id")
  int? schoolId;
  @JsonKey(name: "created_by")
  dynamic createdBy;
  @JsonKey(name: "country_id")
  int? countryId;
  @JsonKey(name: "created_at")
  DateTime? createdAt;
  @JsonKey(name: "state_id")
  int? stateId;
  @JsonKey(name: "updated_at")
  DateTime? updatedAt;
  @JsonKey(name: "city")
  String? city;
  @JsonKey(name: "dob")
  DateTime? dob;
  @JsonKey(name: "user")
  StudentUser? user;

  Student({
    this.id,
    this.score,
    this.userId,
    this.points,
    this.gradeId,
    this.likes,
    this.schoolId,
    this.createdBy,
    this.countryId,
    this.createdAt,
    this.stateId,
    this.updatedAt,
    this.city,
    this.dob,
    this.user,
  });

  Student copyWith({
    int? id,
    int? score,
    int? userId,
    int? points,
    int? gradeId,
    int? likes,
    int? schoolId,
    dynamic createdBy,
    int? countryId,
    DateTime? createdAt,
    int? stateId,
    DateTime? updatedAt,
    String? city,
    DateTime? dob,
    StudentUser? user,
  }) =>
      Student(
        id: id ?? this.id,
        score: score ?? this.score,
        userId: userId ?? this.userId,
        points: points ?? this.points,
        gradeId: gradeId ?? this.gradeId,
        likes: likes ?? this.likes,
        schoolId: schoolId ?? this.schoolId,
        createdBy: createdBy ?? this.createdBy,
        countryId: countryId ?? this.countryId,
        createdAt: createdAt ?? this.createdAt,
        stateId: stateId ?? this.stateId,
        updatedAt: updatedAt ?? this.updatedAt,
        city: city ?? this.city,
        dob: dob ?? this.dob,
        user: user ?? this.user,
      );

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);
}

@JsonSerializable()
class StudentUser {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "email")
  String? email;
  @JsonKey(name: "image")
  dynamic image;
  @JsonKey(name: "role_id")
  int? roleId;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "role")
  StudentRole? role;

  StudentUser({
    this.name,
    this.email,
    this.image,
    this.roleId,
    this.id,
    this.role,
  });

  StudentUser copyWith({
    String? name,
    String? email,
    dynamic image,
    int? roleId,
    int? id,
    StudentRole? role,
  }) =>
      StudentUser(
        name: name ?? this.name,
        email: email ?? this.email,
        image: image ?? this.image,
        roleId: roleId ?? this.roleId,
        id: id ?? this.id,
        role: role ?? this.role,
      );

  factory StudentUser.fromJson(Map<String, dynamic> json) => _$StudentUserFromJson(json);

  Map<String, dynamic> toJson() => _$StudentUserToJson(this);
}

@JsonSerializable()
class StudentRole {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "created_by")
  int? createdBy;
  @JsonKey(name: "id")
  int? id;

  StudentRole({
    this.name,
    this.createdBy,
    this.id,
  });

  StudentRole copyWith({
    String? name,
    int? createdBy,
    int? id,
  }) =>
      StudentRole(
        name: name ?? this.name,
        createdBy: createdBy ?? this.createdBy,
        id: id ?? this.id,
      );

  factory StudentRole.fromJson(Map<String, dynamic> json) => _$StudentRoleFromJson(json);

  Map<String, dynamic> toJson() => _$StudentRoleToJson(this);
}
