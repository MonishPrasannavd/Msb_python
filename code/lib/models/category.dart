import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';
import 'package:msb_app/models/category_type.dart';

part 'category.g.dart';

@JsonSerializable(explicitToJson: true)
class Category with CopyWithMixin<Category> {
  final String id;
  final String name;
  final List<CategoryType> types;

  Category({
    required this.id,
    required this.name,
    required this.types,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  Category copyWith({
    String? id,
    String? name,
    List<CategoryType>? types,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      types: types ?? this.types,
    );
  }
}

