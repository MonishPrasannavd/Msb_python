import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'grade.g.dart';

@JsonSerializable()
class Grade {
  @JsonKey(name: "created_by")
  dynamic createdBy;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "name")
  String? name;

  Grade({
    this.createdBy,
    this.id,
    this.name,
  });

  Grade copyWith({
    dynamic createdBy,
    int? id,
    String? name,
  }) =>
      Grade(
        createdBy: createdBy ?? this.createdBy,
        id: id ?? this.id,
        name: name ?? this.name,
      );

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);

  Map<String, dynamic> toJson() => _$GradeToJson(this);
}
