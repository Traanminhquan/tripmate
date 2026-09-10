import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip_model.dart';

class TripRemoteDataSource {
  final FirebaseFirestore firestore;

  TripRemoteDataSource({
    required this.firestore,
  });

  Future<String> createTrip(
    TripModel trip,
  ) async {
    final document =
        firestore.collection('trips').doc();

    final data = trip.toMap();

    data['createdAt'] =
        FieldValue.serverTimestamp();

    await document.set(data);

    return document.id;
  }

  Future<List<TripModel>> getTripsByUser(
    String userId,
  ) async {
    final snapshot = await firestore
        .collection('trips')
        .where(
          'ownerId',
          isEqualTo: userId,
        )
        .orderBy('startDate')
        .get();

    return snapshot.docs.map((doc) {
      return TripModel.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();
  }

  Future<TripModel?> getTripById(
    String tripId,
  ) async {
    final document = await firestore
        .collection('trips')
        .doc(tripId)
        .get();

    if (!document.exists) {
      return null;
    }

    return TripModel.fromMap(
      document.id,
      document.data()!,
    );
  }

  Future<void> updateTrip(
    TripModel trip,
  ) async {
    await firestore
        .collection('trips')
        .doc(trip.id)
        .update(
          trip.toMap(),
        );
  }

  Future<void> deleteTrip(
    String tripId,
  ) async {
    await firestore
        .collection('trips')
        .doc(tripId)
        .delete();
  }
}