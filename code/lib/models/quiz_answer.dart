import 'package:json_annotation/json_annotation.dart';

part 'quiz_answer.g.dart';

@JsonSerializable()
class QuizAnswer {
  final String questionId;
  final String selectedAnswerId;

  QuizAnswer({
    required this.questionId,
    required this.selectedAnswerId,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) => _$QuizAnswerFromJson(json);
  Map<String, dynamic> toJson() => _$QuizAnswerToJson(this);
}