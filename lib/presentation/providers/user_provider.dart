import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/user_repository.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userRemoteDataSourceProvider =
    Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(
    firestore: ref.read(firestoreProvider),
  );
});

final userRepositoryProvider =
    Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remoteDataSource:
        ref.read(userRemoteDataSourceProvider),
  );
});

final currentUserProfileProvider =
    FutureProvider.family<AppUser?, String>((ref, uid) {
  return ref.read(userRepositoryProvider).getUser(uid);
});