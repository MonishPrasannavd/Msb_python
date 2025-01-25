import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msb_app/models/comment.dart';
import 'package:msb_app/repository/repository.dart';

class CommentRepository implements IRepository<CommentPost> {
  final CollectionReference commentCollection;

  CommentRepository({required this.commentCollection});

  @override
  Future<CommentPost?> getOne(String id) async {
    try {
      DocumentSnapshot snapshot = await commentCollection.doc(id).get();
      if (snapshot.exists) {
        return CommentPost.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching comment by id: $e');
      return null;
    }
  }

  @override
  Future<List<CommentPost>> getAll() async {
    try {
      QuerySnapshot snapshot = await commentCollection.get();
      return snapshot.docs.map((doc) => CommentPost.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching all comments: $e');
      return [];
    }
  }

  @override
  Future<CommentPost?> saveOne(CommentPost entry) async {
    try {
      DocumentReference docRef = await commentCollection.add(entry.toJson());
      DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        return CommentPost.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error saving comment: $e');
      return null;
    }
  }

  @override
  Future<List<CommentPost>> saveAll(List<CommentPost> entries) async {
    List<CommentPost> savedComments = [];
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      for (var entry in entries) {
        DocumentReference docRef = commentCollection.doc();
        batch.set(docRef, entry.toJson());
      }
      await batch.commit();
      savedComments = entries;
    } catch (e) {
      print('Error saving comments: $e');
    }
    return savedComments;
  }

  @override
  Future<bool> updateOne(CommentPost entry) async {
    try {
      QuerySnapshot snapshot = await commentCollection
          .where('userId', isEqualTo: entry.userId)
          .where('postId', isEqualTo: entry.postId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await commentCollection.doc(snapshot.docs.first.id).update(entry.toJson());
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating comment: $e');
      return false;
    }
  }

  @override
  Future<bool> updateAll(List<CommentPost> entries) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    bool success = true;

    try {
      for (var entry in entries) {
        QuerySnapshot snapshot = await commentCollection
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
      print('Error updating comments: $e');
    }
    return success;
  }

  @override
  Future<bool> deleteOne(CommentPost entry) async {
    try {
      QuerySnapshot snapshot = await commentCollection
          .where('userId', isEqualTo: entry.userId)
          .where('postId', isEqualTo: entry.postId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await commentCollection.doc(snapshot.docs.first.id).delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting comment: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteAll(List<CommentPost> entries) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    bool success = true;

    try {
      for (var entry in entries) {
        QuerySnapshot snapshot = await commentCollection
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
      print('Error deleting comments: $e');
    }
    return success;
  }

  // Fetch all comments for a specific post
  Future<List<CommentPost>> getCommentsByPost(String postId) async {
    try {
      QuerySnapshot snapshot = await commentCollection.where('postId', isEqualTo: postId).get();

      return snapshot.docs.map((doc) => CommentPost.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching comments for post: $e');
      return [];
    }
  }

  // Fetch all comments made by a specific user
  Future<List<CommentPost>> getCommentsByUser(String userId) async {
    try {
      QuerySnapshot snapshot = await commentCollection.where('userId', isEqualTo: userId).get();

      return snapshot.docs.map((doc) => CommentPost.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching comments by user: $e');
      return [];
    }
  }

  // Fetch comments for multiple postIds
  Future<List<CommentPost>> getCommentsByPostIds(List<String> postIds) async {
    try {
      if (postIds.isEmpty) {
        return [];
      }
      QuerySnapshot snapshot = await commentCollection.where('postId', whereIn: postIds).get();

      return snapshot.docs.map((doc) => CommentPost.fromJson(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching comments by postIds: $e');
      return [];
    }
  }

  Future<int> getCommentCountsByPostIds(List<String> postIds) async {
    try {
      AggregateQuerySnapshot snapshot = await commentCollection.where('postId', whereIn: postIds).count().get();

      return snapshot.count ?? 0;
    } catch (e) {
      print('Error fetching comment count for post: $e');
      return 0;
    }
  }
}
