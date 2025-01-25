import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/repository/repository.dart';

class UserRepository implements IRepository<MsbUser> {
  final CollectionReference usersCollection;

  // Constructor for dependency injection
  UserRepository({required this.usersCollection});

  @override
  Future<bool> deleteAll(List<MsbUser> entries) async {
    try {
      for (var entry in entries) {
        if (entry.id != null) {
          await usersCollection.doc(entry.id).delete();
        }
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> deleteOne(MsbUser entry) async {
    try {
      if (entry.id != null) {
        await usersCollection.doc(entry.id).delete();
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<List<MsbUser>> getAll() async {
    try {
      QuerySnapshot snapshot = await usersCollection.get();
      List<MsbUser> users = snapshot.docs.map((doc) {
        return MsbUser.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      return users;
    } catch (e) {
      print(e);
      throw Exception("Error fetching users");
    }
  }

  Future<List<MsbUser>> getAllExcept({
    required List<String> userIds,
    List<String>? schoolIds,
  }) async {
    try {
      List<MsbUser> allUsers = [];
      List<String> validSchoolIds = schoolIds ?? [];
      QuerySnapshot snap = await usersCollection
          // .where('id', whereNotIn: userIds)
          .where('schoolId', whereIn: schoolIds)
          .get();

      for (var doc in snap.docs) {
        var user = MsbUser.fromJson(doc.data() as Map<String, dynamic>);
        if (user.id != null && !userIds.contains(user.id)) {
          allUsers.add(user);
        }
      }

      return allUsers;
    } catch (e) {
      print("Error fetching users except those in the list: $e");
      throw Exception("Error fetching users");
    }
  }

  @override
  Future<MsbUser?> getOne(String userId) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return MsbUser.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print(e);
      throw Exception("Error fetching user");
    }
  }

  @override
  Future<List<MsbUser>> saveAll(List<MsbUser> entries) async {
    try {
      // Save all users in parallel and collect the document references
      List<DocumentReference> docRefs = await Future.wait(
        entries.map((entry) => usersCollection.add(entry.toJson())).toList(),
      );

      // Assign the generated document ID back to each user and return the updated list
      List<MsbUser> savedUsers = entries.asMap().entries.map((entry) {
        int index = entry.key;
        MsbUser user = entry.value;
        return MsbUser(
          id: docRefs[index].id, // Set the document ID from Firestore
          name: user.name,
          email: user.email,
          phone: user.phone,
        );
      }).toList();

      return savedUsers;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Future<MsbUser?> saveOne(MsbUser entry) async {
    try {
      DocumentReference docRef = await usersCollection.add(entry.toJson());
      return entry.copyWith(id: docRef.id); // Return the MsbUser with the generated ID
    } catch (e) {
      print(e);
      return null; // Return null or handle error appropriately
    }
  }

  @override
  Future<bool> updateAll(List<MsbUser> entries) async {
    try {
      for (var entry in entries) {
        if (entry.id != null) {
          await usersCollection.doc(entry.id).update(entry.toJson());
        }
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> updateOne(MsbUser entry) async {
    try {
      if (entry.id != null) {
        await usersCollection.doc(entry.id).update(entry.toJson());
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<MsbUser>> getTopUsersByPoints({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await usersCollection
          .orderBy('totalPoints', descending: true) // Order by totalPoints in descending order
          .limit(limit) // Limit the result to the top `limit` users (default is 10)
          .get();

      List<MsbUser> topUsers = snapshot.docs.map((doc) {
        return MsbUser.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return topUsers;
    } catch (e) {
      print("Error fetching top users: $e");
      throw Exception("Error fetching top users");
    }
  }

  Future<int> getTotalUserCount() async {
    try {
      AggregateQuerySnapshot querySnapshot = await usersCollection.count().get();
      return querySnapshot.count ?? 0;
    } catch (e) {
      print("Error getting total user count: $e");
      throw Exception("Error getting total user count");
    }
  }

  Future<List<MsbUser>> getTopUsersBySchoolId(String schoolId, {int limit = 3}) async {
    try {
      // Query to filter users by `schoolId` and order by `totalPoints` in descending order
      QuerySnapshot snapshot = await usersCollection
          .where('schoolId', isEqualTo: schoolId) // Filter by `schoolId`
          .orderBy('totalPoints', descending: true) // Order by `totalPoints` descending
          .limit(limit) // Limit to the top `limit` users (default 3)
          .get();

      // Map the results to `MsbUser` objects
      List<MsbUser> topUsers = snapshot.docs.map((doc) {
        return MsbUser.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return topUsers;
    } catch (e) {
      print("Error fetching top users by schoolId: $e");
      throw Exception("Error fetching top users by schoolId");
    }
  }

  Future<List<MsbUser>> getUsersBySchoolId(String schoolId, {int limit = 10, String? lastDocumentId}) async {
    try {
      Query query = usersCollection.where('schoolId', isEqualTo: schoolId).limit(limit);

      // If a lastDocumentId is provided, start after the document with that ID for pagination
      if (lastDocumentId != null) {
        DocumentSnapshot lastDocument = await usersCollection.doc(lastDocumentId).get();
        query = query.startAfterDocument(lastDocument);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return MsbUser.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error fetching users by schoolId with pagination: $e");
      throw Exception("Error fetching users by schoolId with pagination");
    }
  }
}
