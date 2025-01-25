import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';

part 'quiz.g.dart';

@JsonSerializable(explicitToJson: true)
class Quiz with CopyWithMixin<Quiz> {
  final String id;
  final String name;
  final List<String> questionIds;
  final String createdBy;

  Quiz({
    required this.id,
    required this.name,
    required this.questionIds,
    required this.createdBy,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => _$QuizFromJson(json);

  Map<String, dynamic> toJson() => _$QuizToJson(this);

  @override
  Quiz copyWith({
    String? id,
    String? name,
    List<String>? questionIds,
    String? createdBy,
  }) {
    return Quiz(
      id: id ?? this.id,
      name: name ?? this.name,
      questionIds: questionIds ?? this.questionIds,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
