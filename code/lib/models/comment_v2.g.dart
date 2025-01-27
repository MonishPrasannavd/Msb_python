// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      userId: (json['user_id'] as num?)?.toInt(),
      schoolId: (json['school_id'] as num?)?.toInt(),
      parentId: json['parent_id'],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      id: (json['id'] as num?)?.toInt(),
      submissionId: (json['submission_id'] as num?)?.toInt(),
      comment: json['comment'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'user_id': instance.userId,
      'school_id': instance.schoolId,
      'parent_id': instance.parentId,
      'created_at': instance.createdAt?.toIso8601String(),
      'id': instance.id,
      'submission_id': instance.submissionId,
      'comment': instance.comment,
      'user': instance.user,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      name: json['name'] as String?,
      email: json['email'] as String?,
      image: json['image'],
      roleId: (json['role_id'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      imageUrl: json['image_url'],
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'image': instance.image,
      'role_id': instance.roleId,
      'id': instance.id,
      'image_url': instance.imageUrl,
    };
