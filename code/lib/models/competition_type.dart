import 'package:json_annotation/json_annotation.dart';
import '../mixins/copy_with_mixin.dart';

part 'competition_type.g.dart';

@JsonSerializable(explicitToJson: true)
class CompetitionType with CopyWithMixin<CompetitionType> {
  final String id;
  final String competitionNames; // e.g., "Grade 1-3"
  final String competitionLastDate;

  CompetitionType({
    required this.id,
    required this.competitionNames,
    required this.competitionLastDate,
  });

  factory CompetitionType.fromJson(Map<String, dynamic> json) =>
      _$CompetitionTypeFromJson(json);

  Map<String, dynamic> toJson() => _$CompetitionTypeToJson(this);

  @override
  CompetitionType copyWith({
    String? id,
    String? competitionNames,
    String? competitionLastDate,
  }) {
    return CompetitionType(
      id: id ?? this.id,
      competitionNames: competitionNames ?? this.competitionNames,
      competitionLastDate: competitionLastDate ?? this.competitionLastDate,
    );
  }
}
