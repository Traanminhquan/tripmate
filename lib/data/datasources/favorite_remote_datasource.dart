import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/favorite_place_model.dart';

class FavoriteRemoteDataSource {
  final FirebaseFirestore firestore;

  FavoriteRemoteDataSource({
    required this.firestore,
  });

  CollectionReference<Map<String, dynamic>>
      _favoritesRef(
    String userId,
  ) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('favorites');
  }

  Future<void> addFavorite({
    required String userId,
    required FavoritePlaceModel place,
  }) async {
    await _favoritesRef(userId)
        .doc(place.id)
        .set({
      ...place.toMap(),
      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite({
    required String userId,
    required String placeId,
  }) async {
    await _favoritesRef(userId)
        .doc(placeId)
        .delete();
  }

  Future<List<FavoritePlaceModel>>
      getFavorites(
    String userId,
  ) async {
    final snapshot =
        await _favoritesRef(userId)
            .orderBy(
              'createdAt',
              descending: true,
            )
            .get();

    return snapshot.docs.map(
      (doc) {
        return FavoritePlaceModel.fromMap(
          doc.id,
          doc.data(),
        );
      },
    ).toList();
  }

  Future<bool> isFavorite({
    required String userId,
    required String placeId,
  }) async {
    final doc =
        await _favoritesRef(userId)
            .doc(placeId)
            .get();

    return doc.exists;
  }
}