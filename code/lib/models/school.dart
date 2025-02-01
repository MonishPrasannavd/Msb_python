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

  School({
    this.name,
    this.id,
    this.createdBy,
  });

  School copyWith({
    String? name,
    int? id,
    int? createdBy,
  }) =>
      School(
        name: name ?? this.name,
        id: id ?? this.id,
        createdBy: createdBy ?? this.createdBy,
      );

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolToJson(this);
}
