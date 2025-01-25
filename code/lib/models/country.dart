import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  @JsonKey(name: "created_by")
  dynamic createdBy;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "id")
  int? id;

  Country({
    this.createdBy,
    this.name,
    this.id,
  });

  Country copyWith({
    dynamic createdBy,
    String? name,
    int? id,
  }) =>
      Country(
        createdBy: createdBy ?? this.createdBy,
        name: name ?? this.name,
        id: id ?? this.id,
      );

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);

  Map<String, dynamic> toJson() => _$CountryToJson(this);
}
