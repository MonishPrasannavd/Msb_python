import 'package:json_annotation/json_annotation.dart';

part 'category_type_v2.g.dart';

@JsonSerializable()
class CategoryTypeV2 {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "id")
  int? id;

  CategoryTypeV2({
    this.name,
    this.id,
  });

  CategoryTypeV2 copyWith({
    String? name,
    int? id,
  }) =>
      CategoryTypeV2(
        name: name ?? this.name,
        id: id ?? this.id,
      );

  factory CategoryTypeV2.fromJson(Map<String, dynamic> json) =>
      _$CategoryTypeV2FromJson(json);

  Map<String, dynamic> toJson() => _$CategoryTypeV2ToJson(this);
}
