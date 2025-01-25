import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';

part 'quiz_record.g.dart';

@JsonSerializable(explicitToJson: true)
class QuizRecord with CopyWithMixin<QuizRecord> {
  final String userId;
  final String quizId;
  final Map<String, String> questionAnswerMap; // Map from questionId to answerId
  final int score; // Store the score for the quiz

  QuizRecord({
    required this.userId,
    required this.quizId,
    required this.questionAnswerMap, // A map of question ID to answer ID
    required this.score, // Quiz score
  });

  factory QuizRecord.fromJson(Map<String, dynamic> json) =>
      _$QuizRecordFromJson(json);

  Map<String, dynamic> toJson() => _$QuizRecordToJson(this);

  @override
  QuizRecord copyWith({
    String? userId,
    String? quizId,
    Map<String, String>? questionAnswerMap,
    int? score,
  }) {
    return QuizRecord(
      userId: userId ?? this.userId,
      quizId: quizId ?? this.quizId,
      questionAnswerMap: questionAnswerMap ?? this.questionAnswerMap,
      score: score ?? this.score,
    );
  }
}
