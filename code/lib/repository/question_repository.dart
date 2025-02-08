import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:msb_app/models/answer.dart';
import 'package:msb_app/models/question.dart';
import 'package:msb_app/repository/repository.dart';
import 'package:msb_app/repository/answer_repository.dart';

class QuestionRepository implements IRepository<Question> {
  final CollectionReference questionsCollection;
  final AnswerRepository answerRepository;

  // Constructor for dependency injection
  QuestionRepository({
    required this.questionsCollection,
    required this.answerRepository,
  });

  @override
  Future<Question?> getOne(String id) async {
    try {
      DocumentSnapshot doc = await questionsCollection.doc(id).get();
      if (doc.exists) {
        var questionData =
            Question.fromJson(doc.data() as Map<String, dynamic>);

        // Fetch answers for this question using the answerRepository
        List<String> answerIds = questionData.answerIds;
        List<Answer> answerObjects =
            await answerRepository.getAnswersByIds(answerIds);

        return questionData.copyWith(answers: answerObjects);
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Error fetching question");
    }
  }

  @override
  Future<List<Question>> getAll() async {
    try {
      QuerySnapshot snapshot = await questionsCollection.get();
      List<Question> questions = snapshot.docs.map((doc) {
        return Question.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      return questions;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Error fetching questions");
    }
  }

  @override
  Future<Question?> saveOne(Question entry) async {
    try {
      DocumentReference docRef = await questionsCollection.add(entry.toJson());
      return entry.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<List<Question>> saveAll(List<Question> entries) async {
    try {
      List<DocumentReference> docRefs = await Future.wait(
        entries
            .map((entry) => questionsCollection.add(entry.toJson()))
            .toList(),
      );

      List<Question> savedQuestions = entries.asMap().entries.map((entry) {
        int index = entry.key;
        Question question = entry.value;
        return question.copyWith(id: docRefs[index].id);
      }).toList();

      return savedQuestions;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<bool> updateOne(Question entry) async {
    try {
      await questionsCollection.doc(entry.id).update(entry.toJson());
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<bool> updateAll(List<Question> entries) async {
    try {
      for (var entry in entries) {
        await questionsCollection.doc(entry.id).update(entry.toJson());
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<bool> deleteOne(Question entry) async {
    try {
      await questionsCollection.doc(entry.id).delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  @override
  Future<bool> deleteAll(List<Question> entries) async {
    try {
      for (var entry in entries) {
        await questionsCollection.doc(entry.id).delete();
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
