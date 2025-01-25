// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryType _$CategoryTypeFromJson(Map<String, dynamic> json) => CategoryType(
      id: json['id'] as String,
      name: json['name'] as String,
      quizIds:
          (json['quizIds'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CategoryTypeToJson(CategoryType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quizIds': instance.quizIds,
    };
