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
      avgPoints: (json['avg_points'] as num?)?.toDouble(),
      topStudents: (json['top_students'] as List<dynamic>?)
          ?.map((e) => TopStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
      topLikeSubmissions: (json['top_like_submissions'] as List<dynamic>?)
          ?.map((e) => TopLikeSubmission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SchoolDashboardToJson(SchoolDashboard instance) =>
    <String, dynamic>{
      'students_count': instance.studentsCount,
      'submissions_count': instance.submissionsCount,
      'submissions_likes': instance.submissionsLikes,
      'avg_points': instance.avgPoints,
      'top_students': instance.topStudents,
      'top_like_submissions': instance.topLikeSubmissions,
    };

TopLikeSubmission _$TopLikeSubmissionFromJson(Map<String, dynamic> json) =>
    TopLikeSubmission(
      id: (json['id'] as num?)?.toInt(),
      gradeId: (json['grade_id'] as num?)?.toInt(),
      schoolId: (json['school_id'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'],
      createdBy: (json['created_by'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      subCategoryId: (json['sub_category_id'] as num?)?.toInt(),
      media: json['media'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      subcategory: json['subcategory'] == null
          ? null
          : Subcategory.fromJson(json['subcategory'] as Map<String, dynamic>),
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      mediaUrl: json['media_url'] as String?,
      likesCount: (json['likes_count'] as num?)?.toInt(),
      commentCounts: (json['comment_counts'] as num?)?.toInt(),
      isLiked: json['is_liked'] as bool?,
    );

Map<String, dynamic> _$TopLikeSubmissionToJson(TopLikeSubmission instance) =>
    <String, dynamic>{
      'id': instance.id,
      'grade_id': instance.gradeId,
      'school_id': instance.schoolId,
      'title': instance.title,
      'description': instance.description,
      'created_at': instance.createdAt,
      'created_by': instance.createdBy,
      'category_id': instance.categoryId,
      'sub_category_id': instance.subCategoryId,
      'media': instance.media,
      'user': instance.user,
      'subcategory': instance.subcategory,
      'category': instance.category,
      'media_url': instance.mediaUrl,
      'likes_count': instance.likesCount,
      'comment_counts': instance.commentCounts,
      'is_liked': instance.isLiked,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num?)?.toInt(),
      icon: json['icon'] as String?,
      type: (json['type'] as num?)?.toInt(),
      name: json['name'] as String?,
      isFuture: (json['is_future'] as num?)?.toInt(),
      iconUrl: json['icon_url'] as String?,
      categoryType: json['category_type'] == null
          ? null
          : CategoryType.fromJson(
              json['category_type'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'type': instance.type,
      'name': instance.name,
      'is_future': instance.isFuture,
      'icon_url': instance.iconUrl,
      'category_type': instance.categoryType,
    };

CategoryType _$CategoryTypeFromJson(Map<String, dynamic> json) => CategoryType(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$CategoryTypeToJson(CategoryType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

Subcategory _$SubcategoryFromJson(Map<String, dynamic> json) => Subcategory(
      icon: json['icon'],
      categoryId: (json['category_id'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$SubcategoryToJson(Subcategory instance) =>
    <String, dynamic>{
      'icon': instance.icon,
      'category_id': instance.categoryId,
      'id': instance.id,
      'name': instance.name,
    };

TopStudent _$TopStudentFromJson(Map<String, dynamic> json) => TopStudent(
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
      gradeId: (json['grade_id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TopStudentToJson(TopStudent instance) =>
    <String, dynamic>{
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
      'grade_id': instance.gradeId,
      'created_at': instance.createdAt?.toIso8601String(),
      'dob': instance.dob?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'user': instance.user,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      resetToken: json['reset_token'],
      isVerified: json['is_verified'] as bool?,
      email: json['email'] as String?,
      image: json['image'] as String?,
      tokenExpiry: json['token_expiry'] == null
          ? null
          : DateTime.parse(json['token_expiry'] as String),
      roleId: (json['role_id'] as num?)?.toInt(),
      students: (json['students'] as List<dynamic>?)
          ?.map((e) => TopStudent.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['image_url'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'reset_token': instance.resetToken,
      'is_verified': instance.isVerified,
      'email': instance.email,
      'image': instance.image,
      'token_expiry': instance.tokenExpiry?.toIso8601String(),
      'role_id': instance.roleId,
      'students': instance.students,
      'image_url': instance.imageUrl,
    };
