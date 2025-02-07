// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

School _$SchoolFromJson(Map<String, dynamic> json) => School(
      name: json['name'] as String?,
      id: (json['id'] as num?)?.toInt(),
      createdBy: (json['created_by'] as num?)?.toInt(),
    )..rank = (json['rank'] as num?)?.toInt();

Map<String, dynamic> _$SchoolToJson(School instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'created_by': instance.createdBy,
      'rank': instance.rank,
    };
