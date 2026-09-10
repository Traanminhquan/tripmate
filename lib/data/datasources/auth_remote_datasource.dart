import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSource({
    required this.firebaseAuth,
  });

  Future<User?> register({
    required String email,
    required String password,
  }) async {
    final credential =
        await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final credential =
        await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user;
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }
}