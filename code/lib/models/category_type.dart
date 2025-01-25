import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';

part 'category_type.g.dart';

@JsonSerializable(explicitToJson: true)
class CategoryType with CopyWithMixin<CategoryType> {
  final String id;
  final String name; // e.g., "Grade 1-3"
  final List<String> quizIds;

  CategoryType({
    required this.id,
    required this.name,
    required this.quizIds,
  });

  factory CategoryType.fromJson(Map<String, dynamic> json) =>
      _$CategoryTypeFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryTypeToJson(this);

  @override
  CategoryType copyWith({
    String? id,
    String? name,
    List<String>? quizIds,
  }) {
    return CategoryType(
      id: id ?? this.id,
      name: name ?? this.name,
      quizIds: quizIds ?? this.quizIds,
    );
  }
}
