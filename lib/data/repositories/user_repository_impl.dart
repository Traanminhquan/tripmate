import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) {
    return remoteDataSource.createUser(
      uid: uid,
      name: name,
      email: email,
    );
  }

  @override
  Future<AppUser?> getUser(String uid) {
    return remoteDataSource.getUser(uid);
  }

  @override
  Future<AppUser?> getUserByEmail(
    String email,
  ) {
    return remoteDataSource.getUserByEmail(
      email,
    );
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    String? bio,
    required List<String> travelPreferences,
  }) {
    return remoteDataSource.updateUserProfile(
      uid: uid,
      name: name,
      bio: bio,
      travelPreferences:
          travelPreferences,
    );
  }
}