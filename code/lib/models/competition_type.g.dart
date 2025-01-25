// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompetitionType _$CompetitionTypeFromJson(Map<String, dynamic> json) =>
    CompetitionType(
      id: json['id'] as String,
      competitionNames: json['competitionNames'] as String,
      competitionLastDate: json['competitionLastDate'] as String,
    );

Map<String, dynamic> _$CompetitionTypeToJson(CompetitionType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'competitionNames': instance.competitionNames,
      'competitionLastDate': instance.competitionLastDate,
    };
