// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carousel_slides.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MsbCarouselSlide _$MsbCarouselSlideFromJson(Map<String, dynamic> json) =>
    MsbCarouselSlide(
      imagePath: json['imagePath'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$MsbCarouselSlideToJson(MsbCarouselSlide instance) =>
    <String, dynamic>{
      'imagePath': instance.imagePath,
      'title': instance.title,
      'description': instance.description,
    };
