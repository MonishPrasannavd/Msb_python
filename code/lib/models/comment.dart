import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';

part 'comment.g.dart';

@JsonSerializable(explicitToJson: true)
class CommentPost with CopyWithMixin<CommentPost> {
  final String userId; // e.g., "Grade 1-3"
  final String nameOrEmail;
  final String postId;
  final String comment;
  final DateTime createdAt;

  CommentPost({
    required this.userId,
    required this.postId,
    required this.comment,
    required this.nameOrEmail,
    required this.createdAt
  });

  factory CommentPost.fromJson(Map<String, dynamic> json) =>
      _$CommentPostFromJson(json);

  Map<String, dynamic> toJson() => _$CommentPostToJson(this);

  @override
  CommentPost copyWith({
    String? userId,
    String? postId,
    String? comment,
    String? nameOrEmail,
  }) {
    return CommentPost(
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      comment: comment ?? this.comment,
      nameOrEmail: nameOrEmail ?? this.nameOrEmail,
      createdAt: createdAt
    );
  }
}
