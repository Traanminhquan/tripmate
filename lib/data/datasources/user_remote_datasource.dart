import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSource({
    required this.firestore,
  });

  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'avatarUrl': null,
      'bio': null,
      'travelPreferences': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUser(String uid) async {
    final document =
        await firestore.collection('users').doc(uid).get();

    if (!document.exists) {
      return null;
    }

    return UserModel.fromMap(
      document.id,
      document.data()!,
    );
  }
}