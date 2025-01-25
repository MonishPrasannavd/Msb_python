// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Competition _$CompetitionFromJson(Map<String, dynamic> json) => Competition(
      id: json['id'] as String,
      categoryName: json['categoryName'] as String,
      competitionNames: (json['competitionNames'] as List<dynamic>)
          .map((e) => CompetitionType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CompetitionToJson(Competition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryName': instance.categoryName,
      'competitionNames':
          instance.competitionNames.map((e) => e.toJson()).toList(),
    };
