import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msb_app/models/category.dart';
import 'package:msb_app/models/category_type.dart';
import 'package:msb_app/models/quiz.dart';
import 'package:msb_app/repository/repository.dart';
import 'package:msb_app/utils/firestore_collections.dart';

class CategoryRepository implements IRepository<Category> {
  final CollectionReference categoriesCollection =
  FirebaseFirestore.instance.collection(FirestoreCollections.categories);

  final CollectionReference quizzesCollection =
  FirebaseFirestore.instance.collection(FirestoreCollections.quizzes);


  @override
  Future<Category?> getOne(String id) async {
    try {
      DocumentSnapshot doc = await categoriesCollection.doc(id).get();
      if (doc.exists) {
        return Category.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print(e);
      throw Exception("Error fetching category");
    }
  }

  @override
  Future<List<Category>> getAll() async {
    try {
      QuerySnapshot snapshot = await categoriesCollection.get();
      return snapshot.docs
          .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e);
      throw Exception("Error fetching categories");
    }
  }

  @override
  Future<Category?> saveOne(Category entry) async {
    try {
      DocumentReference docRef = await categoriesCollection.add(entry.toJson());
      return entry.copyWith(id: docRef.id);  // Return the Category with the generated ID
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Category>> saveAll(List<Category> entries) async {
    try {
      List<DocumentReference> docRefs = await Future.wait(
        entries.map((entry) => categoriesCollection.add(entry.toJson())).toList(),
      );

      // Assign generated document IDs back to each category and return the updated list
      List<Category> savedCategories = entries.asMap().entries.map((entry) {
        int index = entry.key;
        Category category = entry.value;
        return category.copyWith(id: docRefs[index].id);  // Set the Firestore ID
      }).toList();

      return savedCategories;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Future<bool> updateOne(Category entry) async {
    try {
      await categoriesCollection.doc(entry.id).update(entry.toJson());
      return true;
          return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> updateAll(List<Category> entries) async {
    try {
      for (var entry in entries) {
        await categoriesCollection.doc(entry.id).update(entry.toJson());
            }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> deleteOne(Category entry) async {
    try {
      await categoriesCollection.doc(entry.id).delete();
      return true;
          return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> deleteAll(List<Category> entries) async {
    try {
      for (var entry in entries) {
        await categoriesCollection.doc(entry.id).delete();
            }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Method to fetch quizzes for a specific category type
  Future<List<Quiz>> getQuizzesByCategoryType(String categoryId, String typeId) async {
    try {
      // Fetch the category document
      DocumentSnapshot categoryDoc = await categoriesCollection.doc(categoryId).get();

      if (categoryDoc.exists) {
        Category category = Category.fromJson(categoryDoc.data() as Map<String, dynamic>);

        // Find the correct category type by typeId
        CategoryType categoryType = category.types.firstWhere((type) => type.id == typeId);

        // If there are quiz IDs in this category type
        if (categoryType.quizIds.isNotEmpty) {
          // Fetch the quizzes by their IDs
          List<Quiz> quizzes = await Future.wait(
            categoryType.quizIds.map((quizId) async {
              DocumentSnapshot quizDoc = await quizzesCollection.doc(quizId).get();
              if (quizDoc.exists) {
                return Quiz.fromJson(quizDoc.data() as Map<String, dynamic>);
              } else {
                throw Exception("Quiz not found");
              }
            }),
          );

          return quizzes;
        }
      }

      return [];
    } catch (e) {
      print(e);
      throw Exception("Error fetching quizzes for category type");
    }
  }



  // This fetches quizzes with all questions lazily loaded when the user selects the quiz
  Future<Quiz?> getQuizById(String quizId) async {
    try {
      // Using the FirestoreCollections for quiz collection
      CollectionReference quizCollection =
      FirebaseFirestore.instance.collection(FirestoreCollections.quizzes);
      DocumentSnapshot quizDoc = await quizCollection.doc(quizId).get();
      if (quizDoc.exists) {
        return Quiz.fromJson(quizDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print(e);
      throw Exception("Error fetching quiz");
    }
  }
}
