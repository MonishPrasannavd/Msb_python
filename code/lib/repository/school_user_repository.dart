import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msb_app/enums/point_type.dart';
import 'package:msb_app/models/school_user.dart';
import 'package:msb_app/models/user.dart';

abstract class IRepository<T> {
  Future<T?> getOne(String id);

  Future<List<T>> getAll();

  Future<T?> saveOne(T entry);

  Future<List<T>> saveAll(List<T> entries);

  Future<bool> updateOne(T entry);

  Future<bool> updateAll(List<T> entries);

  Future<bool> deleteOne(T entry);

  Future<bool> deleteAll(List<T> entries);
}

class SchoolUserRepository implements IRepository<SchoolUser> {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('school_users');

  @override
  Future<SchoolUser?> getOne(String id) async {
    try {
      DocumentSnapshot doc = await collection.doc(id).get();
      if (doc.exists) {
        return SchoolUser.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching school user: $e");
    }
    return null;
  }

  Future<SchoolUser?> findBySchoolId(String schoolId) async {
    try {
      QuerySnapshot snapshot = await collection
          .where('schoolId', isEqualTo: schoolId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return SchoolUser.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching school user: $e");
    }
    return null;
  }

  @override
  Future<List<SchoolUser>> getAll() async {
    try {
      QuerySnapshot snapshot = await collection.get();
      return snapshot.docs
          .map((doc) => SchoolUser.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching school users: $e");
    }
    return [];
  }

  @override
  Future<SchoolUser?> saveOne(SchoolUser entry) async {
    try {
      DocumentReference docRef = collection.doc();
      entry =
          entry.copyWith(id: docRef.id); // Set the auto-generated document ID
      await docRef.set(entry.toJson());
      return entry;
    } catch (e) {
      print("Error saving school user: $e");
      return null;
    }
  }

  @override
  Future<List<SchoolUser>> saveAll(List<SchoolUser> entries) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    List<SchoolUser> savedEntries = [];

    try {
      for (var entry in entries) {
        DocumentReference docRef = collection.doc();
        SchoolUser newEntry = entry.copyWith(id: docRef.id);
        batch.set(docRef, newEntry.toJson());
        savedEntries.add(newEntry);
      }
      await batch.commit();
      return savedEntries;
    } catch (e) {
      print("Error saving multiple school users: $e");
      return [];
    }
  }

  @override
  Future<bool> updateOne(SchoolUser entry) async {
    try {
      if (entry.id != null) {
        await collection.doc(entry.id).update(entry.toJson());
        return true;
      }
    } catch (e) {
      print("Error updating school user: $e");
    }
    return false;
  }

  @override
  Future<bool> updateAll(List<SchoolUser> entries) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      for (var entry in entries) {
        if (entry.id != null) {
          batch.update(collection.doc(entry.id), entry.toJson());
        }
      }
      await batch.commit();
      return true;
    } catch (e) {
      print("Error updating multiple school users: $e");
    }
    return false;
  }

  @override
  Future<bool> deleteOne(SchoolUser entry) async {
    try {
      if (entry.id != null) {
        await collection.doc(entry.id).delete();
        return true;
      }
    } catch (e) {
      print("Error deleting school user: $e");
    }
    return false;
  }

  @override
  Future<bool> deleteAll(List<SchoolUser> entries) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      for (var entry in entries) {
        if (entry.id != null) {
          batch.delete(collection.doc(entry.id));
        }
      }
      await batch.commit();
      return true;
    } catch (e) {
      print("Error deleting multiple school users: $e");
    }
    return false;
  }

  Future<int> getTotalSchoolCount() async {
    try {
      AggregateQuerySnapshot querySnapshot = await collection.count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      print("Error getting total school count: $e");
      throw Exception("Error getting total school count");
    }
  }

  Future<void> updateSchoolAverageOnUserAddOrUpdate(
      MsbUser? user, double newPoints) async {
    if (user?.schoolId != null) {
      SchoolUser? school = await findBySchoolId(user!.schoolId!);

      if (school != null) {
        // Update the average points and student count
        double updatedTotalPoints =
            (school.averagePoints * school.studentCount) + newPoints;
        int updatedStudentCount = school.studentCount + 1;
        double newAverage = updatedTotalPoints / updatedStudentCount;

        // Update school data
        await updateOne(school.copyWith(
            averagePoints: newAverage, studentCount: updatedStudentCount));
      } else {
        // If the school doesn't exist, create a new entry
        saveOne(SchoolUser(
          schoolId: user.schoolId,
          schoolName: user.schoolName,
          averagePoints: newPoints,
          studentCount: 1,
          createdAt: Timestamp.now(),
        ));
      }
    }
  }

  Future<void> updateStudentPoints(
      MsbUser user, int newPoints, PointType pointType) async {
    if (user.schoolId != null && user.totalPoints != null) {
      var school = await findBySchoolId(user.schoolId!);

      if (school != null) {
        // Calculate total points by subtracting old points and adding new points
        double oldTotalPoints = school.averagePoints * school.studentCount;
        double updatedTotalPoints = oldTotalPoints - (user.totalPoints ?? 0);

        // Calculate new average points
        double newAverage =
            (updatedTotalPoints.abs() + newPoints) / school.studentCount;
        newAverage = newAverage > 0 ? newAverage : 0;
        // Update the school average points in Firestore
        if (pointType == PointType.postSubmission) {
          await updateOne(
            school.copyWith(
                averagePoints: newAverage,
                totalSubmissions: school.totalSubmissions + 1),
          );
        } else {
          await updateOne(
            school.copyWith(
              averagePoints: newAverage,
            ),
          );
        }
      }
    }
  }

  Future<void> updateSchoolAverageOnUserRemove(
      MsbUser user, double removedPoints) async {
    if (user.schoolId != null) {
      DocumentReference schoolDocRef = collection.doc(user.schoolId);
      DocumentSnapshot schoolSnapshot = await schoolDocRef.get();

      if (schoolSnapshot.exists) {
        SchoolUser school =
            SchoolUser.fromJson(schoolSnapshot.data() as Map<String, dynamic>);

        // Remove the student's points and update the average
        double updatedTotalPoints =
            (school.averagePoints * school.studentCount) - removedPoints;
        int updatedStudentCount = school.studentCount - 1;
        double newAverage = updatedStudentCount > 0
            ? updatedTotalPoints / updatedStudentCount
            : 0.0;

        // Update school data
        await schoolDocRef.update({
          'averagePoints': newAverage,
          'studentCount': updatedStudentCount,
        });
      }
    }
  }

  Future<List<SchoolUser>> getTopSchoolsByAveragePoints(
      {int limit = 10}) async {
    try {
      // Query Firestore to get the top schools by averagePoints
      QuerySnapshot snapshot = await collection
          .where('studentCount', isGreaterThan: 0)
          .orderBy('averagePoints',
              descending: true) // Order by average points in descending order
          .limit(limit) // Limit the results to the top `limit` schools
          .get();

      // Map the query results to a list of SchoolUser objects
      List<SchoolUser> topSchools = snapshot.docs.map((doc) {
        return SchoolUser.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      if (topSchools.isEmpty) {
        return getRecentlyJoinedSchools(limit: limit);
      }

      return topSchools;
    } catch (e) {
      print("Error fetching top schools: $e");
      throw Exception("Error fetching top schools");
    }
  }

  Future<List<SchoolUser>> getRecentlyJoinedSchools({int limit = 5}) async {
    try {
      // Query Firestore to get the schools ordered by createdAt
      QuerySnapshot snapshot = await collection
          .orderBy('createdAt',
              descending: true) // Order by createdAt in descending order
          .limit(limit) // Limit the results to `limit`
          .get();

      // Map the query results to a list of SchoolUser objects
      List<SchoolUser> recentlyJoinedSchools = snapshot.docs.map((doc) {
        return SchoolUser.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return recentlyJoinedSchools;
    } catch (e) {
      print("Error fetching recently joined schools: $e");
      throw Exception("Error fetching recently joined schools");
    }
  }

  Future<List<SchoolUser>> getRecentlyJoinedSchoolsPaginated({
    int limit = 10,
    String? lastDocumentId,
  }) async {
    try {
      Query query =
          collection.orderBy('createdAt', descending: true).limit(limit);

      // If `lastDocumentId` is provided, fetch the corresponding DocumentSnapshot
      if (lastDocumentId != null) {
        DocumentSnapshot lastDocSnapshot =
            await collection.doc(lastDocumentId).get();
        if (lastDocSnapshot.exists) {
          query = query.startAfterDocument(lastDocSnapshot);
        }
      }

      // Execute the query
      QuerySnapshot snapshot = await query.get();

      // Map the query results to a list of SchoolUser objects
      return snapshot.docs.map((doc) {
        return SchoolUser.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching paginated recently joined schools: $e");
      throw Exception("Error fetching paginated recently joined schools");
    }
  }

  Future<List<SchoolUser>> searchSchools({
    required String query,
    int limit = 10,
  }) async {
    try {
      // Query Firestore for schools with a case-insensitive search
      QuerySnapshot snapshot = await collection
          .where('schoolName', isGreaterThanOrEqualTo: query)
          .where('schoolName', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('createdAt')
          .limit(limit)
          .get();

      // Map the query results to a list of SchoolUser objects
      return snapshot.docs.map((doc) {
        return SchoolUser.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error searching schools: $e");
      throw Exception("Error searching schools");
    }
  }

  Future<int?> getSchoolRank(String schoolId) async {
    try {
      // Fetch the school details
      SchoolUser? schoolDoc = await findBySchoolId(schoolId);

      if (schoolDoc == null) {
        print("School with ID $schoolId not found");
        return null; // Return null if the school doesn't exist
      }

      double schoolAveragePoints = schoolDoc.averagePoints;

      // Count the number of schools with a higher average points
      QuerySnapshot higherRankedSchools = await collection
          .where('averagePoints', isGreaterThan: schoolAveragePoints)
          .get();

      // The rank is one more than the count of schools with higher average points
      return higherRankedSchools.docs.length + 1;
    } catch (e) {
      print("Error calculating school rank: $e");
      throw Exception("Error calculating school rank");
    }
  }
}
