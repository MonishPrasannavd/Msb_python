import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msb_app/enums/point_type.dart';
import 'package:msb_app/models/post_feed.dart';
import 'package:msb_app/repository/repository.dart';
import 'package:msb_app/repository/school_user_repository.dart'
    as SchoolUserRepo;
import 'package:msb_app/services/points_system.dart';

import '../utils/firestore_collections.dart';

class PostFeedRepository implements IRepository<PostFeed> {
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection(FirestoreCollections.posts);
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection(FirestoreCollections.users);
  final SchoolUserRepo.SchoolUserRepository schoolUserRepository =
      SchoolUserRepo.SchoolUserRepository();

  @override
  Future<PostFeed?> getOne(String id) async {
    try {
      DocumentSnapshot doc = await postsCollection.doc(id).get();
      if (doc.exists) {
        return PostFeed.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error getting post: $e");
    }
    return null;
  }

  @override
  Future<List<PostFeed>> getAll() async {
    try {
      QuerySnapshot snapshot = await postsCollection
          .where('isHidden', isEqualTo: false)
          .orderBy('createdAt',
              descending: true) // Apply descending order by createdAt
          .get();
      return snapshot.docs
          .map((doc) => PostFeed.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting all posts: $e");
    }
    return [];
  }

  @override
  Future<PostFeed?> saveOne(PostFeed entry) async {
    try {
      if (entry.id == null) {
        String documentId = postsCollection.doc().id;
        entry = entry.copyWith(id: documentId);
      }
      await postsCollection.doc(entry.id).set(entry.toJson());

      if (entry.userId != null) {
        PointsSystem.updateUserPoints(
            userId: entry.userId!, pointType: PointType.postSubmission);
      }
      return entry;
    } catch (e) {
      print("Error saving post: $e");
    }
    return null;
  }

  @override
  Future<List<PostFeed>> saveAll(List<PostFeed> entries) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var entry in entries) {
        String documentId = entry.id ?? postsCollection.doc().id;
        entry = entry.copyWith(id: documentId);
        batch.set(postsCollection.doc(documentId), entry.toJson());
      }
      await batch.commit();
      return entries;
    } catch (e) {
      print("Error saving posts: $e");
    }
    return [];
  }

  @override
  Future<bool> updateOne(PostFeed entry) async {
    try {
      await postsCollection.doc(entry.id).update(entry.toJson());
      return true;
    } catch (e) {
      print("Error updating post: $e");
      return false;
    }
  }

  @override
  Future<bool> updateAll(List<PostFeed> entries) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var entry in entries) {
        batch.update(postsCollection.doc(entry.id), entry.toJson());
      }
      await batch.commit();
      return true;
    } catch (e) {
      print("Error updating posts: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteOne(PostFeed entry) async {
    try {
      await postsCollection.doc(entry.id).delete();
      return true;
    } catch (e) {
      print("Error deleting post: $e");
      return false;
    }
  }

  @override
  Future<bool> deleteAll(List<PostFeed> entries) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var entry in entries) {
        batch.delete(postsCollection.doc(entry.id));
      }
      await batch.commit();
      return true;
    } catch (e) {
      print("Error deleting posts: $e");
      return false;
    }
  }

  // Toggle the isHidden flag
  Future<bool> toggleIsHidden(String postId) async {
    try {
      PostFeed? postFeed = await getOne(postId);
      if (postFeed != null) {
        bool newIsHidden = !postFeed.isHidden;
        await postsCollection.doc(postId).update({'isHidden': newIsHidden});
        return true;
      }
    } catch (e) {
      print("Error toggling isHidden flag: $e");
    }
    return false;
  }

  // Toggle the commentsEnabled flag
  Future<bool> toggleCommentsEnabled(String postId) async {
    try {
      PostFeed? postFeed = await getOne(postId);
      if (postFeed != null) {
        bool newCommentsEnabled = !postFeed.commentsEnabled;
        await postsCollection
            .doc(postId)
            .update({'commentsEnabled': newCommentsEnabled});
        return true;
      }
    } catch (e) {
      print("Error toggling commentsEnabled flag: $e");
    }
    return false;
  }

  Future<List<PostFeed>> getTopPostsByLikesInSchool(String schoolId,
      {int limit = 10, bool includeHidden = false}) async {
    try {
      Query query = postsCollection.where('schoolId', isEqualTo: schoolId);

      // Apply the isHidden filter if includeHidden is false
      if (!includeHidden) {
        query = query.where('isHidden', isEqualTo: false);
      }

      // Sort by the number of likes (size of likedBy array) in descending order
      query = query.orderBy('likedBy', descending: true).limit(limit);

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PostFeed.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching top posts by likes in school: $e");
      return [];
    }
  }

  // Get all posts for a specific user
  Future<List<PostFeed>> getPostsByUserId(String userId,
      {bool includeHidden = false}) async {
    try {
      Query query = postsCollection.where('userId', isEqualTo: userId);

      if (!includeHidden) {
        query = query.where('isHidden', isEqualTo: false);
      }

      QuerySnapshot snapshot = await query
          .orderBy('createdAt',
              descending: true) // Apply descending order by createdAt
          .get();
      return snapshot.docs
          .map((doc) => PostFeed.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting posts by userId: $e");
    }
    return [];
  }

  Future<bool> addLikedByForPost(
      String postId, String userId, bool userHasLiked) async {
    try {
      await postsCollection.doc(postId).update({
        'likedBy': userHasLiked
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId])
      });

      var fetchPost = await postsCollection.doc(postId).get();
      var post = PostFeed.fromJson(fetchPost.data() as Map<String, dynamic>);
      if (userHasLiked) {
        PointsSystem.updateUserPoints(
            userId: post.userId!, pointType: PointType.postDislike);
      } else {
        PointsSystem.updateUserPoints(
            userId: post.userId!, pointType: PointType.postLike);
      }
      return true;
    } catch (e) {
      print("Error toggling commentsEnabled flag: $e");
    }
    return false;
  }

  // Get all posts for a specific user
  Future<List<PostFeed>> getPostsByCategoryId(
      {required String postCategory, bool includeHidden = false}) async {
    try {
      Query query =
          postsCollection.where('postCategory', isEqualTo: postCategory);

      if (!includeHidden) {
        query = query.where('isHidden', isEqualTo: false);
      }

      QuerySnapshot snapshot = await query
          .orderBy('createdAt',
              descending: true) // Apply descending order by createdAt
          .get();
      return snapshot.docs
          .map((doc) => PostFeed.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting posts by userId: $e");
    }
    return [];
  }

  // Get all posts for a specific school
  Future<List<PostFeed>> getPostsBySchoolId(String schoolId,
      {bool includeHidden = false}) async {
    try {
      Query query = postsCollection.where('schoolId', isEqualTo: schoolId);

      if (!includeHidden) {
        query = query.where('isHidden', isEqualTo: false);
      }

      QuerySnapshot snapshot = await query
          .orderBy('createdAt',
              descending: true) // Apply descending order by createdAt
          .get();
      return snapshot.docs
          .map((doc) => PostFeed.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting posts by schoolId: $e");
    }
    return [];
  }

  // Get all posts that do not match a specific userId
  Future<List<PostFeed>> getPostsExcludingUserId(String userId,
      {bool includeHidden = false, String? schoolId, String? sClass}) async {
    try {
      // Create a query to exclude posts from the provided userId
      Query query = postsCollection.where('userId', isNotEqualTo: userId);

      // Apply `isHidden` filter if `includeHidden` is false
      if (!includeHidden) {
        query = query.where('isHidden', isEqualTo: false);
      }

      if (schoolId != null) {
        query = query.where('schoolId', isEqualTo: schoolId);
      }

      if (sClass != null) {
        query = query.where('grade', isEqualTo: sClass);
      }

      QuerySnapshot snapshot = await query
          .orderBy('createdAt',
              descending: true) // Apply descending order by createdAt
          .get();
      return snapshot.docs
          .map((doc) => PostFeed.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting posts excluding userId: $e");
    }
    return [];
  }

  // Get the total number of likes for posts by schoolId with default isHidden filter
  Future<int> getTotalLikesBySchoolId(String schoolId,
      {bool isHidden = false}) async {
    try {
      var posts = await getPostsBySchoolId(schoolId);

      int totalLikes = posts.fold(0, (int sum, PostFeed post) {
        List<String> likedBy = post.likedBy;
        return sum + likedBy.length;
      });

      return totalLikes;
    } catch (e) {
      print("Error getting total likes by schoolId: $e");
      return 0;
    }
  }

  /// Fetches recent submissions by school ID, with an optional limit on the number of results.
  /// The default limit is 10 submissions, ordered by `createdAt` in descending order.
  ///
  /// Parameters:
  /// - `schoolId`: The school ID to filter submissions by.
  /// - `limit`: The maximum number of submissions to retrieve (default is 10).
  /// - `includeHidden`: Whether to include hidden posts in the results (default is `false`).
  Future<List<PostFeed>> getRecentSubmissionsBySchoolId(String schoolId,
      {int limit = 10, bool includeHidden = false}) async {
    try {
      // Start the query with filtering by `schoolId`
      Query query = postsCollection
          .where('schoolId', isEqualTo: schoolId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // Apply `isHidden` filter only if `includeHidden` is `false`
      if (!includeHidden) {
        query = query.where('isHidden', isEqualTo: false);
      }

      // Execute the query and map results to `PostFeed` model
      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PostFeed.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting recent submissions by schoolId: $e");
      return [];
    }
  }

  Future<List<PostFeed>> getRecentForUserBySchoolId(String schoolId,
      {int limit = 10, bool includeHidden = false}) async {
    try {
      // Step 1: Fetch the most recent submission for the given school ID
      Query userQuery = postsCollection
          .where('schoolId', isEqualTo: schoolId)
          .orderBy('createdAt', descending: true)
          .limit(1);

      // Apply `isHidden` filter only if `includeHidden` is `false`
      if (!includeHidden) {
        userQuery = userQuery.where('isHidden', isEqualTo: false);
      }

      QuerySnapshot userSnapshot = await userQuery.get();
      if (userSnapshot.docs.isEmpty) {
        return []; // Return an empty list if no submissions are found
      }

      // Get the `userId` from the most recent submission
      String? userId = (userSnapshot.docs.first.data()
          as Map<String, dynamic>)['userId'] as String?;
      if (userId == null) {
        return []; // Return an empty list if `userId` is null
      }

      // Step 2: Fetch all recent submissions by the same user
      Query query = postsCollection
          .where('schoolId', isEqualTo: schoolId)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // Apply `isHidden` filter only if `includeHidden` is `false`
      if (!includeHidden) {
        query = query.where('isHidden', isEqualTo: false);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PostFeed.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error getting recent submissions for user by schoolId: $e");
      return [];
    }
  }

  Future<List<PostFeed>> getTopPostsByTopUserInSchool(String schoolId,
      {int limit = 3}) async {
    try {
      // Step 1: Fetch the user with the highest points in the given school
      QuerySnapshot userSnapshot = await usersCollection
          .where('schoolId', isEqualTo: schoolId)
          .orderBy('totalPoints', descending: true)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        print("No users found in the school with ID: $schoolId");
        return []; // Return an empty list if no users found
      }

      // Get the userId of the top user
      String userId = userSnapshot.docs.first.id;

      // Step 2: Fetch the top posts by this user
      QuerySnapshot postsSnapshot = await postsCollection
          .where('schoolId', isEqualTo: schoolId)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      // Map the results to PostFeed objects
      List<PostFeed> topPosts = postsSnapshot.docs.map((doc) {
        return PostFeed.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return topPosts;
    } catch (e) {
      print("Error fetching top posts by the top user in school: $e");
      return [];
    }
  }
}
