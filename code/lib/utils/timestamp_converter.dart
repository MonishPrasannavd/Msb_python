import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<Timestamp, dynamic> {
  const TimestampConverter();

  @override
  Timestamp fromJson(dynamic json) {
    if (json is Timestamp) {
      return json;
    } else if (json is Map<String, dynamic>) {
      // Handle Firebase Timestamp object with seconds and nanoseconds
      final seconds = json['seconds'] as int;
      final nanoseconds = json['nanoseconds'] as int;
      return Timestamp(seconds, nanoseconds);
    } else {
      throw ArgumentError('Invalid timestamp format: $json');
    }
  }

  @override
  dynamic toJson(Timestamp timestamp) => timestamp;
}
