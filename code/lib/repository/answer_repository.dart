import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:msb_app/models/answer.dart';
import 'package:msb_app/repository/repository.dart';

class AnswerRepository implements IRepository<Answer> {
  final CollectionReference answersCollection;

  // Constructor for dependency injection
  AnswerRepository({required this.answersCollection});

  @override
  Future<Answer?> getOne(String id) async {
    try {
      DocumentSnapshot doc = await answersCollection.doc(id).get();
      if (doc.exists) {
        return Answer.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print(e);
      throw Exception("Error fetching answer");
    }
  }

  Future<List<Answer>> getAnswersByIds(List<String> answerIds) async {
    try {
      QuerySnapshot snapshot = await answersCollection
          .where(FieldPath.documentId, whereIn: answerIds)
          .get();

      return snapshot.docs
          .map((doc) => Answer.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e);
      throw Exception("Error fetching answers");
    }
  }

  @override
  Future<List<Answer>> getAll() async {
    try {
      QuerySnapshot snapshot = await answersCollection.get();
      List<Answer> answers = snapshot.docs.map((doc) {
        return Answer.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      return answers;
    } catch (e) {
      print(e);
      throw Exception("Error fetching answers");
    }
  }

  @override
  Future<Answer?> saveOne(Answer entry) async {
    try {
      DocumentReference docRef = await answersCollection.add(entry.toJson());
      return entry.copyWith(id: docRef.id);
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Future<List<Answer>> saveAll(List<Answer> entries) async {
    try {
      List<DocumentReference> docRefs = await Future.wait(
        entries.map((entry) => answersCollection.add(entry.toJson())).toList(),
      );

      List<Answer> savedAnswers = entries.asMap().entries.map((entry) {
        int index = entry.key;
        Answer answer = entry.value;
        return answer.copyWith(id: docRefs[index].id);
      }).toList();

      return savedAnswers;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Future<bool> updateOne(Answer entry) async {
    try {
      await answersCollection.doc(entry.id).update(entry.toJson());
      return true;
          return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> updateAll(List<Answer> entries) async {
    try {
      for (var entry in entries) {
        await answersCollection.doc(entry.id).update(entry.toJson());
            }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> deleteOne(Answer entry) async {
    try {
      await answersCollection.doc(entry.id).delete();
      return true;
          return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> deleteAll(List<Answer> entries) async {
    try {
      for (var entry in entries) {
        await answersCollection.doc(entry.id).delete();
            }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
