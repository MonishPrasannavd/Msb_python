import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/models/comment_v2.dart';

part 'submission.g.dart';

@JsonSerializable()
class Submission {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "category_id")
  int? categoryId;
  @JsonKey(name: "sub_category_id")
  int? subCategoryId;
  @JsonKey(name: "school_id")
  int? schoolId;
  @JsonKey(name: "description")
  String? description;
  @JsonKey(name: "created_at")
  dynamic createdAt;
  @JsonKey(name: "created_by")
  int? createdBy;
  @JsonKey(name: "grade_id")
  int? gradeId;
  @JsonKey(name: "title")
  String? title;
  @JsonKey(name: "media")
  String? media;
  @JsonKey(name: "user")
  User? user;
  @JsonKey(name: "category")
  Category? category;
  @JsonKey(name: "subcategory")
  Subcategory? subcategory;
  @JsonKey(name: "media_url")
  String? mediaUrl;
  @JsonKey(name: "likes_count")
  int? likesCount;
  @JsonKey(name: "is_liked")
  bool? isLiked;
  @JsonKey(name: "comments_count")
  int? commentsCount;
  @JsonKey(name: "comments")
  List<Comment> comments;

  Submission({
    this.id,
    this.categoryId,
    this.subCategoryId,
    this.schoolId,
    this.description,
    this.createdAt,
    this.createdBy,
    this.gradeId,
    this.title,
    this.media,
    this.user,
    this.category,
    this.subcategory,
    this.mediaUrl,
    this.likesCount,
    this.isLiked,
    this.commentsCount,
    this.comments = const []
  });

  Submission copyWith({
    int? id,
    int? categoryId,
    int? subCategoryId,
    int? schoolId,
    String? description,
    dynamic createdAt,
    int? createdBy,
    int? gradeId,
    String? title,
    String? media,
    User? user,
    Category? category,
    Subcategory? subcategory,
    String? mediaUrl,
    int? likesCount,
    bool? isLiked,
  }) =>
      Submission(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        subCategoryId: subCategoryId ?? this.subCategoryId,
        schoolId: schoolId ?? this.schoolId,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        gradeId: gradeId ?? this.gradeId,
        title: title ?? this.title,
        media: media ?? this.media,
        user: user ?? this.user,
        category: category ?? this.category,
        subcategory: subcategory ?? this.subcategory,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        likesCount: likesCount ?? this.likesCount,
        isLiked: isLiked ?? this.isLiked,
      );

  factory Submission.fromJson(Map<String, dynamic> json) =>
      _$SubmissionFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionToJson(this);
}

@JsonSerializable()
class Category {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "is_future")
  int? isFuture;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "icon")
  String? icon;
  @JsonKey(name: "type")
  int? type;
  @JsonKey(name: "category_type")
  CategoryType? categoryType;
  @JsonKey(name: "icon_url")
  String? iconUrl;

  Category({
    this.id,
    this.isFuture,
    this.name,
    this.icon,
    this.type,
    this.categoryType,
    this.iconUrl,
  });

  Category copyWith({
    int? id,
    int? isFuture,
    String? name,
    String? icon,
    int? type,
    CategoryType? categoryType,
    String? iconUrl,
  }) =>
      Category(
        id: id ?? this.id,
        isFuture: isFuture ?? this.isFuture,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        type: type ?? this.type,
        categoryType: categoryType ?? this.categoryType,
        iconUrl: iconUrl ?? this.iconUrl,
      );

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class CategoryType {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "id")
  int? id;

  CategoryType({
    this.name,
    this.id,
  });

  CategoryType copyWith({
    String? name,
    int? id,
  }) =>
      CategoryType(
        name: name ?? this.name,
        id: id ?? this.id,
      );

  factory CategoryType.fromJson(Map<String, dynamic> json) =>
      _$CategoryTypeFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryTypeToJson(this);
}

@JsonSerializable()
class Subcategory {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "category_id")
  int? categoryId;
  @JsonKey(name: "icon")
  dynamic icon;
  @JsonKey(name: "name")
  String? name;

  Subcategory({
    this.id,
    this.categoryId,
    this.icon,
    this.name,
  });

  Subcategory copyWith({
    int? id,
    int? categoryId,
    dynamic icon,
    String? name,
  }) =>
      Subcategory(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        icon: icon ?? this.icon,
        name: name ?? this.name,
      );

  factory Subcategory.fromJson(Map<String, dynamic> json) =>
      _$SubcategoryFromJson(json);

  Map<String, dynamic> toJson() => _$SubcategoryToJson(this);
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
  @JsonKey(name: "students")
  List<Student>? students;

  User({
    this.name,
    this.email,
    this.image,
    this.roleId,
    this.id,
    this.students,
  });

  User copyWith({
    String? name,
    String? email,
    dynamic image,
    int? roleId,
    int? id,
    List<Student>? students,
  }) =>
      User(
        name: name ?? this.name,
        email: email ?? this.email,
        image: image ?? this.image,
        roleId: roleId ?? this.roleId,
        id: id ?? this.id,
        students: students ?? this.students,
      );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Student {
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
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "dob")
  DateTime? dob;
  @JsonKey(name: "score")
  int? score;

  Student({
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
    this.id,
    this.dob,
    this.score,
  });

  Student copyWith({
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
    int? id,
    DateTime? dob,
    int? score,
  }) =>
      Student(
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
        id: id ?? this.id,
        dob: dob ?? this.dob,
        score: score ?? this.score,
      );

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);

  Map<String, dynamic> toJson() => _$StudentToJson(this);
}
