import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';

part 'hidden_posts.g.dart';

@JsonSerializable(explicitToJson: true)
class HiddenPosts with CopyWithMixin<HiddenPosts> {
  final String? userId; // e.g., "Grade 1-3"
  final String? postId;

  HiddenPosts({
    required this.userId,
    required this.postId,
  });

  factory HiddenPosts.fromJson(Map<String, dynamic> json) =>
      _$HiddenPostsFromJson(json);

  Map<String, dynamic> toJson() => _$HiddenPostsToJson(this);

  @override
  HiddenPosts copyWith({
    String? userId,
    String? postId,
  }) {
    return HiddenPosts(
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
    );
  }
}
