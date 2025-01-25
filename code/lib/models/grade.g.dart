// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Grade _$GradeFromJson(Map<String, dynamic> json) => Grade(
      createdBy: json['created_by'],
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$GradeToJson(Grade instance) => <String, dynamic>{
      'created_by': instance.createdBy,
      'id': instance.id,
      'name': instance.name,
    };
