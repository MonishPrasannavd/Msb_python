
import 'package:json_annotation/json_annotation.dart';

part 'carousel_slides.g.dart';

@JsonSerializable(explicitToJson: true)
class MsbCarouselSlide {
  final String imagePath;
  final String? title;
  final String? description;

  MsbCarouselSlide({
    required this.imagePath,
    this.title,
    this.description,
  });

  factory MsbCarouselSlide.fromJson(Map<String, dynamic> json) => _$MsbCarouselSlideFromJson(json);

  Map<String, dynamic> toJson() => _$MsbCarouselSlideToJson(this);
}
