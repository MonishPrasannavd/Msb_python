import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';
import 'package:msb_app/models/answer.dart';

part 'question.g.dart';

@JsonSerializable(explicitToJson: true)
class Question with CopyWithMixin<Question> {
  final String id;
  final String questionText;
  final List<String> answerIds;
  final List<Answer>? answers;

  Question({
    required this.id,
    required this.questionText,
    required this.answerIds,
    this.answers = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  @override
  Question copyWith({
    String? id,
    String? questionText,
    List<String>? answerIds,
    List<Answer>? answers
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      answerIds: answerIds ?? this.answerIds,
      answers: answers ?? this.answers
    );
  }
}
