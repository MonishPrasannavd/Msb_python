import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'school_rank.g.dart';

@JsonSerializable()
class SchoolRank {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "created_by")
  int? createdBy;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "rank")
  int? rank;

  SchoolRank({
    this.id,
    this.createdBy,
    this.name,
    this.rank,
  });

  SchoolRank copyWith({
    int? id,
    int? createdBy,
    String? name,
    int? rank,
  }) =>
      SchoolRank(
        id: id ?? this.id,
        createdBy: createdBy ?? this.createdBy,
        name: name ?? this.name,
        rank: rank ?? this.rank,
      );

  factory SchoolRank.fromJson(Map<String, dynamic> json) => _$SchoolRankFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolRankToJson(this);
}
