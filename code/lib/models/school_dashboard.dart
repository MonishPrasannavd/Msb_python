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
  @JsonKey(name: "avg_points")
  double? avgPoints;
  @JsonKey(name: "top_students")
  List<TopStudent>? topStudents;
  @JsonKey(name: "top_like_submissions")
  List<TopLikeSubmission>? topLikeSubmissions;

  SchoolDashboard({
    this.studentsCount,
    this.submissionsCount,
    this.submissionsLikes,
    this.avgPoints,
    this.topStudents,
    this.topLikeSubmissions,
  });

  SchoolDashboard copyWith({
    int? studentsCount,
    int? submissionsCount,
    int? submissionsLikes,
    double? avgPoints,
    List<TopStudent>? topStudents,
    List<TopLikeSubmission>? topLikeSubmissions,
  }) =>
      SchoolDashboard(
        studentsCount: studentsCount ?? this.studentsCount,
        submissionsCount: submissionsCount ?? this.submissionsCount,
        submissionsLikes: submissionsLikes ?? this.submissionsLikes,
        avgPoints: avgPoints ?? this.avgPoints,
        topStudents: topStudents ?? this.topStudents,
        topLikeSubmissions: topLikeSubmissions ?? this.topLikeSubmissions,
      );

  factory SchoolDashboard.fromJson(Map<String, dynamic> json) => _$SchoolDashboardFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolDashboardToJson(this);
}

@JsonSerializable()
class TopLikeSubmission {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "grade_id")
  int? gradeId;
  @JsonKey(name: "school_id")
  int? schoolId;
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "description")
  String? description;
  @JsonKey(name: "created_at")
  dynamic createdAt;
  @JsonKey(name: "created_by")
  int? createdBy;
  @JsonKey(name: "category_id")
  int? categoryId;
  @JsonKey(name: "sub_category_id")
  int? subCategoryId;
  @JsonKey(name: "media")
  String? media;
  @JsonKey(name: "user")
  User? user;
  @JsonKey(name: "subcategory")
  Subcategory? subcategory;
  @JsonKey(name: "category")
  Category? category;
  @JsonKey(name: "media_url")
  String? mediaUrl;
  @JsonKey(name: "likes_count")
  int? likesCount;
  @JsonKey(name: "comment_counts")
  int? commentCounts;
  @JsonKey(name: "is_liked")
  bool? isLiked;

  TopLikeSubmission({
    this.id,
    this.gradeId,
    this.schoolId,
    this.title,
    this.description,
    this.createdAt,
    this.createdBy,
    this.categoryId,
    this.subCategoryId,
    this.media,
    this.user,
    this.subcategory,
    this.category,
    this.mediaUrl,
    this.likesCount,
    this.commentCounts,
    this.isLiked,
  });

  TopLikeSubmission copyWith({
    int? id,
    int? gradeId,
    int? schoolId,
    String? title,
    String? description,
    dynamic createdAt,
    int? createdBy,
    int? categoryId,
    int? subCategoryId,
    String? media,
    User? user,
    Subcategory? subcategory,
    Category? category,
    String? mediaUrl,
    int? likesCount,
    int? commentCounts,
    bool? isLiked,
  }) =>
      TopLikeSubmission(
        id: id ?? this.id,
        gradeId: gradeId ?? this.gradeId,
        schoolId: schoolId ?? this.schoolId,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        categoryId: categoryId ?? this.categoryId,
        subCategoryId: subCategoryId ?? this.subCategoryId,
        media: media ?? this.media,
        user: user ?? this.user,
        subcategory: subcategory ?? this.subcategory,
        category: category ?? this.category,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        likesCount: likesCount ?? this.likesCount,
        commentCounts: commentCounts ?? this.commentCounts,
        isLiked: isLiked ?? this.isLiked,
      );

  factory TopLikeSubmission.fromJson(Map<String, dynamic> json) => _$TopLikeSubmissionFromJson(json);

  Map<String, dynamic> toJson() => _$TopLikeSubmissionToJson(this);
}

@JsonSerializable()
class Category {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "icon")
  String? icon;
  @JsonKey(name: "type")
  int? type;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "is_future")
  int? isFuture;
  @JsonKey(name: "icon_url")
  String? iconUrl;
  @JsonKey(name: "category_type")
  CategoryType? categoryType;

  Category({
    this.id,
    this.icon,
    this.type,
    this.name,
    this.isFuture,
    this.iconUrl,
    this.categoryType,
  });

  Category copyWith({
    int? id,
    String? icon,
    int? type,
    String? name,
    int? isFuture,
    String? iconUrl,
    CategoryType? categoryType,
  }) =>
      Category(
        id: id ?? this.id,
        icon: icon ?? this.icon,
        type: type ?? this.type,
        name: name ?? this.name,
        isFuture: isFuture ?? this.isFuture,
        iconUrl: iconUrl ?? this.iconUrl,
        categoryType: categoryType ?? this.categoryType,
      );

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class CategoryType {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "name")
  String? name;

  CategoryType({
    this.id,
    this.name,
  });

  CategoryType copyWith({
    int? id,
    String? name,
  }) =>
      CategoryType(
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory CategoryType.fromJson(Map<String, dynamic> json) => _$CategoryTypeFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryTypeToJson(this);
}

@JsonSerializable()
class Subcategory {
  @JsonKey(name: "icon")
  dynamic icon;
  @JsonKey(name: "category_id")
  int? categoryId;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "name")
  String? name;

  Subcategory({
    this.icon,
    this.categoryId,
    this.id,
    this.name,
  });

  Subcategory copyWith({
    dynamic icon,
    int? categoryId,
    int? id,
    String? name,
  }) =>
      Subcategory(
        icon: icon ?? this.icon,
        categoryId: categoryId ?? this.categoryId,
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory Subcategory.fromJson(Map<String, dynamic> json) => _$SubcategoryFromJson(json);

  Map<String, dynamic> toJson() => _$SubcategoryToJson(this);
}

@JsonSerializable()
class TopStudent {
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
  @JsonKey(name: "grade_id")
  int? gradeId;
  @JsonKey(name: "created_at")
  DateTime? createdAt;
  @JsonKey(name: "dob")
  DateTime? dob;
  @JsonKey(name: "updated_at")
  DateTime? updatedAt;
  @JsonKey(name: "user")
  User? user;

  TopStudent({
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
    this.gradeId,
    this.createdAt,
    this.dob,
    this.updatedAt,
    this.user,
  });

  TopStudent copyWith({
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
    int? gradeId,
    DateTime? createdAt,
    DateTime? dob,
    DateTime? updatedAt,
    User? user,
  }) =>
      TopStudent(
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
        gradeId: gradeId ?? this.gradeId,
        createdAt: createdAt ?? this.createdAt,
        dob: dob ?? this.dob,
        updatedAt: updatedAt ?? this.updatedAt,
        user: user ?? this.user,
      );

  factory TopStudent.fromJson(Map<String, dynamic> json) => _$TopStudentFromJson(json);

  Map<String, dynamic> toJson() => _$TopStudentToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "reset_token")
  dynamic resetToken;
  @JsonKey(name: "is_verified")
  bool? isVerified;
  @JsonKey(name: "email")
  String? email;
  @JsonKey(name: "image")
  String? image;
  @JsonKey(name: "token_expiry")
  DateTime? tokenExpiry;
  @JsonKey(name: "role_id")
  int? roleId;
  @JsonKey(name: "students")
  List<TopStudent>? students;
  @JsonKey(name: "image_url")
  String? imageUrl;

  User({
    this.id,
    this.name,
    this.resetToken,
    this.isVerified,
    this.email,
    this.image,
    this.tokenExpiry,
    this.roleId,
    this.students,
    this.imageUrl,
  });

  User copyWith({
    int? id,
    String? name,
    dynamic resetToken,
    bool? isVerified,
    String? email,
    String? image,
    DateTime? tokenExpiry,
    int? roleId,
    List<TopStudent>? students,
    String? imageUrl,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        resetToken: resetToken ?? this.resetToken,
        isVerified: isVerified ?? this.isVerified,
        email: email ?? this.email,
        image: image ?? this.image,
        tokenExpiry: tokenExpiry ?? this.tokenExpiry,
        roleId: roleId ?? this.roleId,
        students: students ?? this.students,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
