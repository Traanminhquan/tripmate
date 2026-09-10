import '../entities/app_user.dart';

abstract class UserRepository {
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  });

  Future<AppUser?> getUser(String uid);
}