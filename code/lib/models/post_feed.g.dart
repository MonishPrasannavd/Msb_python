// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostFeed _$PostFeedFromJson(Map<String, dynamic> json) => PostFeed(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      postType: json['postType'] as String?,
      postCompilation: json['postCompilation'] as String?,
      nameOrEmail: json['nameOrEmail'] as String?,
      isHidden: json['isHidden'] as bool? ?? false,
      commentsEnabled: json['commentsEnabled'] as bool? ?? true,
      schoolName: json['schoolName'] as String?,
      grade: json['grade'] as String?,
      schoolId: json['schoolId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      postCategory: json['postCategory'] as String?,
      likedBy: (json['likedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PostFeedToJson(PostFeed instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'nameOrEmail': instance.nameOrEmail,
      'title': instance.title,
      'description': instance.description,
      'postCategory': instance.postCategory,
      'postCompilation': instance.postCompilation,
      'mediaUrls': instance.mediaUrls,
      'postType': instance.postType,
      'createdAt': instance.createdAt.toIso8601String(),
      'isHidden': instance.isHidden,
      'commentsEnabled': instance.commentsEnabled,
      'schoolId': instance.schoolId,
      'schoolName': instance.schoolName,
      'grade': instance.grade,
      'likedBy': instance.likedBy,
      'comments': instance.comments,
    };
