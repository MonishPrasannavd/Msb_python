// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
      id: json['id'] as String,
      answerText: json['answerText'] as String,
      isCorrect: json['isCorrect'] as bool,
    );

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
      'id': instance.id,
      'answerText': instance.answerText,
      'isCorrect': instance.isCorrect,
    };
