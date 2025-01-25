import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:msb_app/models/user.dart';
import 'package:msb_app/repository/user_repository.dart';

import 'user_repository_test.mocks.dart';

@GenerateMocks([CollectionReference, DocumentReference, DocumentSnapshot, QuerySnapshot, QueryDocumentSnapshot])
void main() {
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQueryDocumentSnapshot mockQueryDocumentSnapshot;
  late UserRepository userRepository;

  setUp(() {
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

    userRepository = UserRepository(usersCollection: mockCollectionReference);
  });

  group('UserRepository', () {
    late MsbUser mockUser = MsbUser(name: 'John Doe', email: 'john@example.com', phone: '1234567890');
    String generatedId = 'generatedId';
    test('saveOne saves a user and returns the saved user with generated ID', () async {
      // Arrange
      when(mockCollectionReference.add(mockUser.toJson())).thenAnswer((_) async => mockDocumentReference);
      when(mockDocumentReference.id).thenReturn(generatedId);

      // Act
      final result = await userRepository.saveOne(mockUser);

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals(generatedId));
      verify(mockCollectionReference.add(mockUser.toJson())).called(1);
      print('Saved result: ${result.toJson()}');
      mockUser = result;
    });

    test('getAll retrieves all users', () async {
      // Arrange
      when(mockCollectionReference.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockQueryDocumentSnapshot.data()).thenReturn(mockUser.toJson());

      // Act
      final result = await userRepository.getAll();

      // Assert
      expect(result.length, equals(1));
      expect(result[0].id, equals(generatedId));
      expect(result[0].name, equals('John Doe'));
      verify(mockCollectionReference.get()).called(1);
    });

    test('updateOne updates a user', () async {
      // Arrange
      when(mockCollectionReference.doc(mockUser.id)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.update(mockUser.toJson())).thenAnswer((_) async {});

      // Act
      final result = await userRepository.updateOne(mockUser);

      // Assert
      expect(result, isTrue);
      verify(mockDocumentReference.update(mockUser.toJson())).called(1);
    });

    test('deleteOne deletes a user', () async {
      // Arrange
      when(mockCollectionReference.doc(mockUser.id)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.delete()).thenAnswer((_) async {});

      // Act
      final result = await userRepository.deleteOne(mockUser);

      // Assert
      expect(result, isTrue);
      verify(mockDocumentReference.delete()).called(1);
    });
  });
}
