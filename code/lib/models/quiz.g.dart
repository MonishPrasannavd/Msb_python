// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quiz _$QuizFromJson(Map<String, dynamic> json) => Quiz(
      id: json['id'] as String,
      name: json['name'] as String,
      questionIds: (json['questionIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdBy: json['createdBy'] as String,
    );

Map<String, dynamic> _$QuizToJson(Quiz instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'questionIds': instance.questionIds,
      'createdBy': instance.createdBy,
    };
