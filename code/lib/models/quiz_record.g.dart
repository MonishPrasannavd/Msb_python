// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizRecord _$QuizRecordFromJson(Map<String, dynamic> json) => QuizRecord(
      userId: json['userId'] as String,
      quizId: json['quizId'] as String,
      questionAnswerMap:
          Map<String, String>.from(json['questionAnswerMap'] as Map),
      score: (json['score'] as num).toInt(),
    );

Map<String, dynamic> _$QuizRecordToJson(QuizRecord instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'quizId': instance.quizId,
      'questionAnswerMap': instance.questionAnswerMap,
      'score': instance.score,
    };
