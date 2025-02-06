// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_type_v2.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryTypeV2 _$CategoryTypeV2FromJson(Map<String, dynamic> json) =>
    CategoryTypeV2(
      name: json['name'] as String?,
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CategoryTypeV2ToJson(CategoryTypeV2 instance) =>
    <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
    };
