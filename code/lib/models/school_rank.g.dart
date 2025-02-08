// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_rank.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SchoolRank _$SchoolRankFromJson(Map<String, dynamic> json) => SchoolRank(
      id: (json['id'] as num?)?.toInt(),
      createdBy: (json['created_by'] as num?)?.toInt(),
      name: json['name'] as String?,
      rank: (json['rank'] as num?)?.toInt(),
      points: (json['points'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SchoolRankToJson(SchoolRank instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_by': instance.createdBy,
      'name': instance.name,
      'rank': instance.rank,
      'points': instance.points,
    };
