import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:msb_app/models/hidden_posts.dart';

// Define the abstract repository interface
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

// HiddenPosts repository implementation
class HiddenPostsRepository implements IRepository<HiddenPosts> {
  final CollectionReference hiddenPostsCollection;

  HiddenPostsRepository({required this.hiddenPostsCollection});

  // Implementing IRepository methods

  @override
  Future<HiddenPosts?> getOne(String id) async {
    try {
      DocumentSnapshot snapshot = await hiddenPostsCollection.doc(id).get();
      if (snapshot.exists) {
        return HiddenPosts.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching hidden post by id: $e');
      return null;
    }
  }

  @override
  Future<List<HiddenPosts>> getAll() async {
    try {
      QuerySnapshot snapshot = await hiddenPostsCollection.get();
      return snapshot.docs
          .map(
              (doc) => HiddenPosts.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching all hidden posts: $e');
      return [];
    }
  }

  @override
  Future<HiddenPosts?> saveOne(HiddenPosts entry) async {
    try {
      DocumentReference docRef =
          await hiddenPostsCollection.add(entry.toJson());
      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        return HiddenPosts.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error saving hidden post: $e');
      return null;
    }
  }

  @override
  Future<List<HiddenPosts>> saveAll(List<HiddenPosts> entries) async {
    List<HiddenPosts> savedPosts = [];
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      for (var entry in entries) {
        DocumentReference docRef = hiddenPostsCollection.doc();
        batch.set(docRef, entry.toJson());
      }
      await batch.commit();
      savedPosts = entries;
    } catch (e) {
      debugPrint('Error saving hidden posts: $e');
    }
    return savedPosts;
  }

  @override
  Future<bool> updateOne(HiddenPosts entry) async {
    try {
      QuerySnapshot snapshot = await hiddenPostsCollection
          .where('userId', isEqualTo: entry.userId)
          .where('postId', isEqualTo: entry.postId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await hiddenPostsCollection
            .doc(snapshot.docs.first.id)
            .update(entry.toJson());
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating hidden post: $e');
      return false;
    }
  }

  @override
  Future<bool> updateAll(List<HiddenPosts> entries) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    bool success = true;

    try {
      for (var entry in entries) {
        QuerySnapshot snapshot = await hiddenPostsCollection
            .where('userId', isEqualTo: entry.userId)
            .where('postId', isEqualTo: entry.postId)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          batch.update(snapshot.docs.first.reference, entry.toJson());
        }
      }
      await batch.commit();
    } catch (e) {
      success = false;
      debugPrint('Error updating hidden posts: $e');
    }
    return success;
  }

  @override
  Future<bool> deleteOne(HiddenPosts entry) async {
    try {
      QuerySnapshot snapshot = await hiddenPostsCollection
          .where('userId', isEqualTo: entry.userId)
          .where('postId', isEqualTo: entry.postId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await hiddenPostsCollection.doc(snapshot.docs.first.id).delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting hidden post: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteAll(List<HiddenPosts> entries) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    bool success = true;

    try {
      for (var entry in entries) {
        QuerySnapshot snapshot = await hiddenPostsCollection
            .where('userId', isEqualTo: entry.userId)
            .where('postId', isEqualTo: entry.postId)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          batch.delete(snapshot.docs.first.reference);
        }
      }
      await batch.commit();
    } catch (e) {
      success = false;
      debugPrint('Error deleting hidden posts: $e');
    }
    return success;
  }

  // Fetch hidden post by userId and postId
  Future<HiddenPosts?> getHiddenPost(String userId, String postId) async {
    try {
      QuerySnapshot snapshot = await hiddenPostsCollection
          .where('userId', isEqualTo: userId)
          .where('postId', isEqualTo: postId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return HiddenPosts.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching hidden post: $e');
      return null;
    }
  }

  // Fetch all hidden posts by userId
  Future<List<HiddenPosts>> getAllHiddenPostsByUser(String userId) async {
    try {
      QuerySnapshot snapshot =
          await hiddenPostsCollection.where('userId', isEqualTo: userId).get();

      return snapshot.docs
          .map(
              (doc) => HiddenPosts.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching hidden posts: $e');
      return [];
    }
  }
}
