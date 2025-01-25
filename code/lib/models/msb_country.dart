import 'package:json_annotation/json_annotation.dart';

part 'msb_country.g.dart';

@JsonSerializable()
class MsbCountry {
  @JsonKey(name: "created_by")
  dynamic createdBy;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "id")
  int? id;

  MsbCountry({
    this.createdBy,
    this.name,
    this.id,
  });

  MsbCountry copyWith({
    dynamic createdBy,
    String? name,
    int? id,
  }) =>
      MsbCountry(
        createdBy: createdBy ?? this.createdBy,
        name: name ?? this.name,
        id: id ?? this.id,
      );

  factory MsbCountry.fromJson(Map<String, dynamic> json) => _$MsbCountryFromJson(json);

  Map<String, dynamic> toJson() => _$MsbCountryToJson(this);
}
