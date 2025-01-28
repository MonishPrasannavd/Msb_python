import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'comment_v2.g.dart';

@JsonSerializable()
class Comment {
  @JsonKey(name: "user_id")
  int? userId;
  @JsonKey(name: "school_id")
  int? schoolId;
  @JsonKey(name: "parent_id")
  dynamic parentId;
  @JsonKey(name: "created_at")
  DateTime? createdAt;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "submission_id")
  int? submissionId;
  @JsonKey(name: "comment")
  String? comment;
  @JsonKey(name: "user")
  User? user;

  Comment({
    this.userId,
    this.schoolId,
    this.parentId,
    this.createdAt,
    this.id,
    this.submissionId,
    this.comment,
    this.user,
  });

  Comment copyWith({
    int? userId,
    int? schoolId,
    dynamic parentId,
    DateTime? createdAt,
    int? id,
    int? submissionId,
    String? comment,
    User? user,
  }) =>
      Comment(
        userId: userId ?? this.userId,
        schoolId: schoolId ?? this.schoolId,
        parentId: parentId ?? this.parentId,
        createdAt: createdAt ?? this.createdAt,
        id: id ?? this.id,
        submissionId: submissionId ?? this.submissionId,
        comment: comment ?? this.comment,
        user: user ?? this.user,
      );

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class User {
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
  @JsonKey(name: "image_url")
  dynamic imageUrl;

  User({
    this.name,
    this.email,
    this.image,
    this.roleId,
    this.id,
    this.imageUrl,
  });

  User copyWith({
    String? name,
    String? email,
    dynamic image,
    int? roleId,
    int? id,
    dynamic imageUrl,
  }) =>
      User(
        name: name ?? this.name,
        email: email ?? this.email,
        image: image ?? this.image,
        roleId: roleId ?? this.roleId,
        id: id ?? this.id,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
