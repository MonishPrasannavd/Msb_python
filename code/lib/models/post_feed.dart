import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';
import 'package:msb_app/models/comment.dart';

part 'post_feed.g.dart';

@JsonSerializable()
class PostFeed with CopyWithMixin<PostFeed> {
  final String? id;
  final String? userId;
  final String? nameOrEmail;
  final String? title;
  final String? description;
  final String? postCategory;
  final String? postCompilation;
  final List<String>?
      mediaUrls; // Support multiple URLs for videos or other media
  final String? postType; // "video", "audio", or "text"
  final DateTime createdAt;
  bool isHidden = false;
  bool commentsEnabled = false;
  final String schoolId;
  final String? schoolName;
  final String? grade;
  final List<String> likedBy;
  List<CommentPost> comments = [];

  PostFeed({
    this.id,
    this.userId,
    this.title,
    this.description,
    this.mediaUrls, // This will hold the URLs for uploaded media
    this.postType,
    this.postCompilation,
    this.nameOrEmail,
    this.isHidden = false,
    this.commentsEnabled = true,
    this.schoolName,
    this.grade,
    required this.schoolId,
    required this.createdAt,
    this.postCategory,
    this.likedBy = const [],
    this.comments = const [],
  });

  set id(String? value) => id = value;

  factory PostFeed.fromJson(Map<String, dynamic> json) =>
      _$PostFeedFromJson(json);

  Map<String, dynamic> toJson() => _$PostFeedToJson(this);

  @override
  PostFeed copyWith({
    String? id,
    String? userId,
    List<String>? likedBy,
    String? title,
    String? description,
    String? postCompilation,
    List<String>? mediaUrls,
    String? postType,
    DateTime? createdAt,
    bool? isHidden,
    bool? commentsEnabled,
    String? schoolId,
    String? schoolName,
    String? nameOrEmail,
    String? grade,
    List<CommentPost>? comments,
    String? postCategory
  }) {
    return PostFeed(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      postCompilation: postCompilation ?? this.postCompilation,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      postType: postType ?? this.postType,
      createdAt: createdAt ?? this.createdAt,
      isHidden: isHidden ?? this.isHidden,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      schoolId: schoolId ?? this.schoolId,
      nameOrEmail: nameOrEmail ?? this.nameOrEmail,
      schoolName: schoolName ?? this.schoolName,
      likedBy: likedBy ?? this.likedBy,
      grade: grade ?? this.grade,
      comments: comments ?? this.comments,
      postCategory: postCategory ?? this.postCategory
    );
  }
}
