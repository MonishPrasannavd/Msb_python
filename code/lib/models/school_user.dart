import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:msb_app/mixins/copy_with_mixin.dart';
import 'package:msb_app/utils/timestamp_converter.dart';

part 'school_user.g.dart';

@JsonSerializable()
class SchoolUser with CopyWithMixin<SchoolUser> {
  final String? id;
  final String? schoolName;
  final String? schoolId;
  final double averagePoints;
  final int studentCount;
  final int totalSubmissions;

  @TimestampConverter()
  final Timestamp createdAt;

  SchoolUser({
    this.id,
    this.schoolId,
    this.schoolName,
    this.averagePoints = 0.0,
    this.studentCount = 0,
    this.totalSubmissions = 0,
    required this.createdAt,
  });

  set id(String? value) => id = value;

  factory SchoolUser.fromJson(Map<String, dynamic> json) => _$SchoolUserFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolUserToJson(this);

  @override
  SchoolUser copyWith({
    String? id,
    String? schoolName,
    String? schoolId,
    double? averagePoints,
    int? studentCount,
    int? totalSubmissions,
    Timestamp? createdAt,
  }) {
    return SchoolUser(
      id: id ?? this.id,
      schoolName: schoolName ?? this.schoolName,
      schoolId: schoolId ?? this.schoolId,
      averagePoints: averagePoints ?? this.averagePoints,
      studentCount: studentCount ?? this.studentCount,
      totalSubmissions: totalSubmissions ?? this.totalSubmissions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Custom `fromJson` logic for converting a Firebase timestamp to a `DateTime`
  static DateTime _timestampToDateTime(dynamic timestamp) {
    if (timestamp is int) {
      // Assuming the timestamp is in seconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    }
    if (timestamp is double) {
      // Assuming the timestamp is in milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    }
    throw ArgumentError('Invalid timestamp format');
  }

  /// Custom `toJson` logic for converting a `DateTime` to a Firebase-compatible timestamp
  static int _dateTimeToTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000; // Converting to seconds since epoch
  }
}
