import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';

part 'user.g.dart';

@JsonSerializable()
class MsbUser with CopyWithMixin<MsbUser> {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImageUrl; // New field for profile image URL
  final String? grade; // New field for grade
  final String? schoolName; // New field for school name
  final String? schoolId;
  final List<String> follower;
  final int? totalPoints;
  final int? totalPostPoints;
  final int? totalLikePoints;
  final int? totalQuizPoints;
  final String? country;
  final String? state;
  final String? city;
  final String? dob;

  MsbUser({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.profileImageUrl,
    this.grade,
    this.schoolName,
    this.follower = const [],
    this.schoolId,
    this.totalPoints = 0,
    this.totalPostPoints = 0,
    this.totalLikePoints = 0,
    this.totalQuizPoints = 0,
    this.state,
    this.city,
    this.country,
    this.dob,
  });

  set id(String? value) => id = value;

  set name(String? value) => name = value;

  set email(String? value) => email = value;

  set phone(String? value) => phone = value;

  set profileImageUrl(String? value) => profileImageUrl = value;

  set grade(String? value) => grade = value;

  set schoolName(String? value) => schoolName = value;

  set schoolId(String? value) => schoolId = value;

  factory MsbUser.fromJson(Map<String, dynamic> json) => _$MsbUserFromJson(json);

  Map<String, dynamic> toJson() => _$MsbUserToJson(this);

  @override
  MsbUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? grade,
    String? schoolName,
    String? schoolId,
    List<String>? follower,
    int? totalPoints,
  }) {
    return MsbUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      grade: grade ?? this.grade,
      schoolName: schoolName ?? this.schoolName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      schoolId: schoolId ?? this.schoolId,
      follower: follower ?? this.follower,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
