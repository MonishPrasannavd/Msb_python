// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'msb_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MsbState _$MsbStateFromJson(Map<String, dynamic> json) => MsbState(
      createdBy: (json['created_by'] as num?)?.toInt(),
      id: (json['id'] as num?)?.toInt(),
      countryId: (json['country_id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$MsbStateToJson(MsbState instance) => <String, dynamic>{
      'created_by': instance.createdBy,
      'id': instance.id,
      'country_id': instance.countryId,
      'name': instance.name,
    };
