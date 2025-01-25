import 'package:json_annotation/json_annotation.dart';
import '../mixins/copy_with_mixin.dart';
import 'competition_type.dart';

part 'competition_data.g.dart';

@JsonSerializable(explicitToJson: true)
class Competition with CopyWithMixin<Competition> {
  final String id;
  final String categoryName;
  final List<CompetitionType> competitionNames;

  Competition({
    required this.id,
    required this.categoryName,
    required this.competitionNames,
  });

  factory Competition.fromJson(Map<String, dynamic> json) =>
      _$CompetitionFromJson(json);

  Map<String, dynamic> toJson() => _$CompetitionToJson(this);

  @override
  Competition copyWith({
    String? id,
    String? categoryName,
    List<CompetitionType>? competitionNames,
  }) {
    return Competition(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      competitionNames: competitionNames ?? this.competitionNames,
    );
  }
}