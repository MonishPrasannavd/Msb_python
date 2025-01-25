// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizAnswer _$QuizAnswerFromJson(Map<String, dynamic> json) => QuizAnswer(
      questionId: json['questionId'] as String,
      selectedAnswerId: json['selectedAnswerId'] as String,
    );

Map<String, dynamic> _$QuizAnswerToJson(QuizAnswer instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'selectedAnswerId': instance.selectedAnswerId,
    };
