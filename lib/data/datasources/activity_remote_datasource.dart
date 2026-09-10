import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip_activity_model.dart';

class ActivityRemoteDataSource {
  final FirebaseFirestore firestore;

  ActivityRemoteDataSource({
    required this.firestore,
  });

  Future<String> createActivity(
    TripActivityModel activity,
  ) async {
    final document = firestore
        .collection('trips')
        .doc(activity.tripId)
        .collection('activities')
        .doc();

    final data = activity.toMap();

    data['createdAt'] =
        FieldValue.serverTimestamp();

    await document.set(data);

    return document.id;
  }

  Future<List<TripActivityModel>> getActivities(
    String tripId,
  ) async {
    final snapshot = await firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .orderBy('date')
        .orderBy('order')
        .get();

    return snapshot.docs.map((doc) {
      return TripActivityModel.fromMap(
        id: doc.id,
        tripId: tripId,
        map: doc.data(),
      );
    }).toList();
  }

  Future<void> updateActivity(
    TripActivityModel activity,
  ) async {
    await firestore
        .collection('trips')
        .doc(activity.tripId)
        .collection('activities')
        .doc(activity.id)
        .update(
          activity.toMap(),
        );
  }

  Future<void> deleteActivity({
    required String tripId,
    required String activityId,
  }) async {
    await firestore
        .collection('trips')
        .doc(tripId)
        .collection('activities')
        .doc(activityId)
        .delete();
  }
}