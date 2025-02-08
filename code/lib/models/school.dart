import 'package:json_annotation/json_annotation.dart';

part 'school.g.dart';

@JsonSerializable()
class School {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "created_by")
  int? createdBy;
  @JsonKey(name: "rank")
  int? rank;
  @JsonKey(name: 'points')
  double? points;
  @JsonKey(name: 'student_count')
  int? studentCount;

  School({
    this.name,
    this.id,
    this.createdBy,
    this.points,
    this.studentCount,
  });

  School copyWith({
    String? name,
    int? id,
    int? createdBy,
    double? points,
    int? studentCount,
  }) =>
      School(
        name: name ?? this.name,
        id: id ?? this.id,
        createdBy: createdBy ?? this.createdBy,
        points: points ?? this.points,
        studentCount: studentCount ?? this.studentCount,
      );

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolToJson(this);
}
