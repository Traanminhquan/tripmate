import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/favorite_remote_datasource.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/favorite_repository.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

final favoriteRemoteDataSourceProvider =
    Provider<FavoriteRemoteDataSource>(
  (ref) {
    return FavoriteRemoteDataSource(
      firestore:
          ref.read(firestoreProvider),
    );
  },
);

final favoriteRepositoryProvider =
    Provider<FavoriteRepository>(
  (ref) {
    return FavoriteRepositoryImpl(
      remoteDataSource: ref.read(
        favoriteRemoteDataSourceProvider,
      ),
    );
  },
);

final favoritesProvider =
    FutureProvider<List<Place>>(
  (ref) async {
    final user =
        ref.watch(
      firebaseAuthProvider,
    ).currentUser;

    if (user == null) {
      return [];
    }

    return ref
        .read(favoriteRepositoryProvider)
        .getFavorites(user.uid);
  },
);

final isFavoriteProvider =
    FutureProvider.family<
        bool,
        String>(
  (ref, placeId) async {
    final user =
        ref.watch(
      firebaseAuthProvider,
    ).currentUser;

    if (user == null) {
      return false;
    }

    return ref
        .read(favoriteRepositoryProvider)
        .isFavorite(
          userId: user.uid,
          placeId: placeId,
        );
  },
);

class FavoriteController
    extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggleFavorite(
    Place place,
  ) async {
    final user =
        ref.read(
      firebaseAuthProvider,
    ).currentUser;

    if (user == null) {
      throw Exception(
        'User not logged in',
      );
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository =
          ref.read(
        favoriteRepositoryProvider,
      );

      final favorite =
          await repository.isFavorite(
        userId: user.uid,
        placeId: place.id,
      );

      if (favorite) {
        await repository.removeFavorite(
          userId: user.uid,
          placeId: place.id,
        );
      } else {
        await repository.addFavorite(
          userId: user.uid,
          place: place,
        );
      }

      ref.invalidate(
        favoritesProvider,
      );

      ref.invalidate(
        isFavoriteProvider(
          place.id,
        ),
      );
    });
  }
}

final favoriteControllerProvider =
    AsyncNotifierProvider<
        FavoriteController,
        void>(
  FavoriteController.new,
);