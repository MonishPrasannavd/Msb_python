// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Submission _$SchoolFromJson(Map<String, dynamic> json) => Submission(
      id: (json['id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      subCategoryId: (json['sub_category_id'] as num?)?.toInt(),
      schoolId: (json['school_id'] as num?)?.toInt(),
      description: json['description'] as String?,
      createdAt: json['created_at'],
      createdBy: (json['created_by'] as num?)?.toInt(),
      gradeId: (json['grade_id'] as num?)?.toInt(),
      title: json['title'] as String?,
      media: json['media'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      category: json['category'] == null
          ? null
          : Category.fromJson(json['category'] as Map<String, dynamic>),
      subcategory: json['subcategory'] == null
          ? null
          : Subcategory.fromJson(json['subcategory'] as Map<String, dynamic>),
      mediaUrl: json['media_url'] as String?,
      likesCount: (json['likes_count'] as num?)?.toInt(),
      isLiked: json['is_liked'] as bool?,
    );

Map<String, dynamic> _$SchoolToJson(Submission instance) => <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'sub_category_id': instance.subCategoryId,
      'school_id': instance.schoolId,
      'description': instance.description,
      'created_at': instance.createdAt,
      'created_by': instance.createdBy,
      'grade_id': instance.gradeId,
      'title': instance.title,
      'media': instance.media,
      'user': instance.user,
      'category': instance.category,
      'subcategory': instance.subcategory,
      'media_url': instance.mediaUrl,
      'likes_count': instance.likesCount,
      'is_liked': instance.isLiked,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num?)?.toInt(),
      isFuture: (json['is_future'] as num?)?.toInt(),
      name: json['name'] as String?,
      icon: json['icon'] as String?,
      type: (json['type'] as num?)?.toInt(),
      categoryType: json['category_type'] == null
          ? null
          : CategoryType.fromJson(
              json['category_type'] as Map<String, dynamic>),
      iconUrl: json['icon_url'] as String?,
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'is_future': instance.isFuture,
      'name': instance.name,
      'icon': instance.icon,
      'type': instance.type,
      'category_type': instance.categoryType,
      'icon_url': instance.iconUrl,
    };

CategoryType _$CategoryTypeFromJson(Map<String, dynamic> json) => CategoryType(
      name: json['name'] as String?,
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CategoryTypeToJson(CategoryType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
    };

Subcategory _$SubcategoryFromJson(Map<String, dynamic> json) => Subcategory(
      id: (json['id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      icon: json['icon'],
      name: json['name'] as String?,
    );

Map<String, dynamic> _$SubcategoryToJson(Subcategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'icon': instance.icon,
      'name': instance.name,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      name: json['name'] as String?,
      email: json['email'] as String?,
      image: json['image'],
      roleId: (json['role_id'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      students: (json['students'] as List<dynamic>?)
          ?.map((e) => Student.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'image': instance.image,
      'role_id': instance.roleId,
      'id': instance.id,
      'students': instance.students,
    };

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
      userId: (json['user_id'] as num?)?.toInt(),
      points: (json['points'] as num?)?.toInt(),
      gradeId: (json['grade_id'] as num?)?.toInt(),
      likes: (json['likes'] as num?)?.toInt(),
      schoolId: (json['school_id'] as num?)?.toInt(),
      createdBy: json['created_by'],
      countryId: (json['country_id'] as num?)?.toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      stateId: (json['state_id'] as num?)?.toInt(),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      city: json['city'] as String?,
      id: (json['id'] as num?)?.toInt(),
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      score: (json['score'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
      'user_id': instance.userId,
      'points': instance.points,
      'grade_id': instance.gradeId,
      'likes': instance.likes,
      'school_id': instance.schoolId,
      'created_by': instance.createdBy,
      'country_id': instance.countryId,
      'created_at': instance.createdAt?.toIso8601String(),
      'state_id': instance.stateId,
      'updated_at': instance.updatedAt?.toIso8601String(),
      'city': instance.city,
      'id': instance.id,
      'dob': instance.dob?.toIso8601String(),
      'score': instance.score,
    };
