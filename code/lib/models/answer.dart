import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';

part 'answer.g.dart';

@JsonSerializable()
class Answer with CopyWithMixin<Answer> {
  final String id;
  final String answerText;
  final bool isCorrect;

  Answer({
    required this.id,
    required this.answerText,
    required this.isCorrect,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerToJson(this);

  @override
  Answer copyWith({
    String? id,
    String? answerText,
    bool? isCorrect,
  }) {
    return Answer(
      id: id ?? this.id,
      answerText: answerText ?? this.answerText,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}
