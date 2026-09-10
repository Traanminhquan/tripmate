import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip_activity.dart';

class TripActivityModel extends TripActivity {
  const TripActivityModel({
    required super.id,
    required super.tripId,
    required super.title,
    required super.location,
    required super.date,
    required super.startTime,
    super.note,
    required super.order,
    super.createdAt,
  });

  factory TripActivityModel.fromMap({
    required String id,
    required String tripId,
    required Map<String, dynamic> map,
  }) {
    return TripActivityModel(
      id: id,
      tripId: tripId,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      startTime: map['startTime'] ?? '',
      note: map['note'],
      order: map['order'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'note': note,
      'order': order,
    };
  }
}