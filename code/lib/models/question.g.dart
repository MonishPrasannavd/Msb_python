// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      answerIds:
          (json['answerIds'] as List<dynamic>).map((e) => e as String).toList(),
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'id': instance.id,
      'questionText': instance.questionText,
      'answerIds': instance.answerIds,
      'answers': instance.answers?.map((e) => e.toJson()).toList(),
    };
