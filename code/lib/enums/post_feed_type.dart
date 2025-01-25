
import 'package:collection/collection.dart';
import 'package:msb_app/Screens/competition/all_school_competitions.dart';

enum PostFeedType {
  video('video'),
  text('text'),
  image('image'),
  audio('audio');

  final String value;

  const PostFeedType(this.value);

  static PostFeedType? fromValue(String value) {
    // Use a default value instead of null if you want to ensure a fallback.
    return PostFeedType.values.firstWhereOrNull(
          (type) => type.value == value, // Return null if no match is found.
    );
  }
}
