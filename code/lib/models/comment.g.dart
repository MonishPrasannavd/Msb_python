// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentPost _$CommentPostFromJson(Map<String, dynamic> json) => CommentPost(
      userId: json['userId'] as String,
      postId: json['postId'] as String,
      comment: json['comment'] as String,
      nameOrEmail: json['nameOrEmail'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CommentPostToJson(CommentPost instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nameOrEmail': instance.nameOrEmail,
      'postId': instance.postId,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
    };
