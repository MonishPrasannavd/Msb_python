// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
      createdBy: json['created_by'],
      name: json['name'] as String?,
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
      'created_by': instance.createdBy,
      'name': instance.name,
      'id': instance.id,
    };
