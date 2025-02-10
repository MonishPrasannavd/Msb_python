import 'package:json_annotation/json_annotation.dart';

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
  @JsonKey(name: 'avg_points')
  double? averagePoints;
  

  SchoolRank({
    this.id,
    this.createdBy,
    this.name,
    this.rank,
    this.averagePoints,
  });

  SchoolRank copyWith({
    int? id,
    int? createdBy,
    String? name,
    int? rank,
    double? points,
  }) =>
      SchoolRank(
        id: id ?? this.id,
        createdBy: createdBy ?? this.createdBy,
        name: name ?? this.name,
        rank: rank ?? this.rank,
        averagePoints: points ?? this.averagePoints,
      );

  factory SchoolRank.fromJson(Map<String, dynamic> json) =>
      _$SchoolRankFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolRankToJson(this);
}
