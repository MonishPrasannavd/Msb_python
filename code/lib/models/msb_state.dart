import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'msb_state.g.dart';

@JsonSerializable()
class MsbState {
  @JsonKey(name: "created_by")
  int? createdBy;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "country_id")
  int? countryId;
  @JsonKey(name: "name")
  String? name;

  MsbState({
    this.createdBy,
    this.id,
    this.countryId,
    this.name,
  });

  MsbState copyWith({
    int? createdBy,
    int? id,
    int? countryId,
    String? name,
  }) =>
      MsbState(
        createdBy: createdBy ?? this.createdBy,
        id: id ?? this.id,
        countryId: countryId ?? this.countryId,
        name: name ?? this.name,
      );

  factory MsbState.fromJson(Map<String, dynamic> json) => _$MsbStateFromJson(json);

  Map<String, dynamic> toJson() => _$MsbStateToJson(this);
}
