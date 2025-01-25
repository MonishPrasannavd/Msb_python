// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msb_country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MsbCountry _$MsbCountryFromJson(Map<String, dynamic> json) => MsbCountry(
      createdBy: json['created_by'],
      name: json['name'] as String?,
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MsbCountryToJson(MsbCountry instance) =>
    <String, dynamic>{
      'created_by': instance.createdBy,
      'name': instance.name,
      'id': instance.id,
    };
