// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MsbUser _$MsbUserFromJson(Map<String, dynamic> json) => MsbUser(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      grade: json['grade'] as String?,
      schoolName: json['schoolName'] as String?,
      follower: (json['follower'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      schoolId: json['schoolId'] as String?,
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      totalPostPoints: (json['totalPostPoints'] as num?)?.toInt() ?? 0,
      totalLikePoints: (json['totalLikePoints'] as num?)?.toInt() ?? 0,
      totalQuizPoints: (json['totalQuizPoints'] as num?)?.toInt() ?? 0,
      state: json['state'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      dob: json['dob'] as String?,
    );

Map<String, dynamic> _$MsbUserToJson(MsbUser instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'profileImageUrl': instance.profileImageUrl,
      'grade': instance.grade,
      'schoolName': instance.schoolName,
      'schoolId': instance.schoolId,
      'follower': instance.follower,
      'totalPoints': instance.totalPoints,
      'totalPostPoints': instance.totalPostPoints,
      'totalLikePoints': instance.totalLikePoints,
      'totalQuizPoints': instance.totalQuizPoints,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'dob': instance.dob,
    };
