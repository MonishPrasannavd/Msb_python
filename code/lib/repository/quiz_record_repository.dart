import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:msb_app/models/quiz_record.dart';
import 'package:msb_app/repository/repository.dart';
import 'package:msb_app/utils/firestore_collections.dart';

class QuizRecordRepository implements IRepository<QuizRecord> {
  final CollectionReference quizRecordsCollection =
      FirebaseFirestore.instance.collection(FirestoreCollections.quizRecords);

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection(FirestoreCollections.users);

  @override
  Future<QuizRecord?> getOne(String id) async {
    try {
      DocumentSnapshot doc = await quizRecordsCollection.doc(id).get();
      if (doc.exists) {
        return QuizRecord.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Error fetching quiz record");
    }
  }

  @override
  Future<List<QuizRecord>> getAll() async {
    try {
      QuerySnapshot snapshot = await quizRecordsCollection.get();
      return snapshot.docs
          .map((doc) => QuizRecord.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Error fetching quiz records");
    }
  }

  @override
  Future<QuizRecord?> saveOne(QuizRecord entry) async {
    try {
      DocumentReference docRef =
          await quizRecordsCollection.add(entry.toJson());
      return entry.copyWith(quizId: docRef.id);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<List<QuizRecord>> saveAll(List<QuizRecord> entries) async {
    try {
      List<DocumentReference> docRefs = await Future.wait(
        entries
            .map((entry) => quizRecordsCollection.add(entry.toJson()))
            .toList(),
      );

      List<QuizRecord> savedRecords = entries.asMap().entries.map((entry) {
        int index = entry.key;
        QuizRecord record = entry.value;
        return record.copyWith(quizId: docRefs[index].id);
      }).toList();

      return savedRecords;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<bool> updateOne(QuizRecord entry) async {
    try {
      await quizRecordsCollection.doc(entry.quizId).update(entry.toJson());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<bool> updateAll(List<QuizRecord> entries) async {
    try {
      for (var entry in entries) {
        await quizRecordsCollection.doc(entry.quizId).update(entry.toJson());
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<bool> deleteOne(QuizRecord entry) async {
    try {
      await quizRecordsCollection.doc(entry.quizId).delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<bool> deleteAll(List<QuizRecord> entries) async {
    try {
      for (var entry in entries) {
        await quizRecordsCollection.doc(entry.quizId).delete();
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Helper function to get quiz records by user ID
  Future<List<QuizRecord>> getQuizRecordsByUserId(String userId) async {
    try {
      QuerySnapshot snapshot =
          await quizRecordsCollection.where('userId', isEqualTo: userId).get();

      return snapshot.docs
          .map((doc) => QuizRecord.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Error fetching quiz records for user");
    }
  }

  // Helper function to get quiz records by quiz ID
  Future<List<QuizRecord>> getQuizRecordsByQuizId(String quizId) async {
    try {
      QuerySnapshot snapshot =
          await quizRecordsCollection.where('quizId', isEqualTo: quizId).get();

      return snapshot.docs
          .map((doc) => QuizRecord.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Error fetching quiz records for quiz");
    }
  }
}
