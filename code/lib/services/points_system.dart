import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:msb_app/enums/point_type.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/repository/posts_repository.dart';
import 'package:msb_app/repository/school_user_repository.dart';
import 'package:msb_app/utils/firestore_collections.dart';

class PointsSystem {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final SchoolUserRepository schoolUserRepository = SchoolUserRepository();
  static final PostFeedRepository postFeedRepository = PostFeedRepository();

  static double getTotalScore({double? averagePoints = 0.0, int? studentCount = 0}) {
    return (averagePoints ?? 0.0) * (studentCount ?? 0);
  }

  /// This function will update the user's points based on the PointType and specific rules.
  static Future<void> updateUserPoints({
    required String userId, // User's unique ID
    required PointType pointType, // Enum to determine which point to update
    int? correctAnswers, // Used for quiz point calculation
    String? userGrade, // Required for grade-based quiz rule
    String? quizGrade, // Required for grade-based quiz rule
  }) async {
    try {
      // Fetch current user document
      DocumentSnapshot userDoc = await _firestore.collection(FirestoreCollections.users).doc(userId).get();

      if (userDoc.exists) {
        MsbUser user = MsbUser.fromJson(userDoc.data() as Map<String, dynamic>);

        // Initialize variables for point calculation with current points, default to 0 if null
        int totalPostPoints = user.totalPostPoints ?? 0;
        int totalLikePoints = user.totalLikePoints ?? 0;
        int totalQuizPoints = user.totalQuizPoints ?? 0;

        // Logic for updating points based on point type
        switch (pointType) {
          // quiz rule
          case PointType.quiz:
            // Check if the quiz is for the correct grade group
            if (quizGrade != null && userGrade != null) {
              // Extract numeric values from the grade strings
              int userGradeInt = _extractGradeNumber(userGrade);
              List<int> quizGradeRange = _extractGradeRange(quizGrade);

              // Check if user's grade falls within the quiz grade range
              if (userGradeInt >= quizGradeRange[0] && userGradeInt <= quizGradeRange[1]) {
                // Add points for each correct answer
                if (correctAnswers != null) {
                  totalQuizPoints += correctAnswers;
                }
              }
            }
            break;

          // submission rule
          case PointType.postSubmission:
            // Add 20 points for each competition submission
            totalPostPoints += 20;
            break;

          // like rule
          case PointType.postLike:
            // Add 2 points for each like
            totalLikePoints += 1;
            break;

          // dislike rule
          case PointType.postDislike:
            // Deduct 2 points for each dislike
            totalLikePoints -= 1;
            break;
        }

        // Calculate total points
        int totalPoints = totalPostPoints + (totalLikePoints * 2) + totalQuizPoints;

        // Update the Firestore document
        await _firestore.collection(FirestoreCollections.users).doc(userId).update({
          'totalPostPoints': totalPostPoints,
          'totalLikePoints': totalLikePoints,
          'totalQuizPoints': totalQuizPoints,
          'totalPoints': totalPoints,
        });

        // Update the school average points
        if (user.schoolId != null && user.totalPoints != null) {
          await schoolUserRepository.updateStudentPoints(user, totalPoints, pointType);
        }
      } else {
        // If the document doesn't exist, create a new one with the provided points
        await _firestore.collection(FirestoreCollections.users).doc(userId).set({
          'totalPostPoints': pointType == PointType.postSubmission ? 20 : 0,
          'totalLikePoints': pointType == PointType.postLike ? 1 : 0,
          'totalQuizPoints': pointType == PointType.quiz ? (correctAnswers ?? 0) : 0,
          'totalPoints': (correctAnswers ?? 0) +
              (pointType == PointType.postSubmission ? 20 : 0) +
              (pointType == PointType.postLike ? 2 : 0) +
              (pointType == PointType.postDislike ? -2 : 0),
        });
      }
    } catch (e) {
      debugPrint('Error updating points: $e');
    }
  }

  /// Helper function to extract the grade number from a string like "grade 3"
  static int _extractGradeNumber(String grade) {
    return int.parse(grade.split(' ').last);
  }

  /// Helper function to extract grade range from a string like "grade 1 - grade 3"
  static List<int> _extractGradeRange(String gradeRange) {
    List<String> parts = gradeRange.split(' - ');

    // if "grade 1 - grade 3", returns [1, 3]
    return parts.map((part) => int.parse(part.split(' ').last)).toList();
  }

  static Future<void> initialUserPointsUpdate({required String userId, required var posts}) async {
    int totalPostPoints = 0;
    int totalLikePoints = 0;
    totalPostPoints = posts.length * 20;
    for (var post in posts) {
      int likes = post.likedBy.length;
      totalLikePoints += likes;
    }
    int totalPoints = totalPostPoints + (totalLikePoints * 2);
    // Update the Firestore document
    try {
      await _firestore.collection(FirestoreCollections.users).doc(userId).update({
        'totalPostPoints': totalPostPoints,
        'totalLikePoints': totalLikePoints,
        'totalPoints': totalPoints,
      });
    } catch (e) {
      print('Error updating points: $e');
    }
  }
}
