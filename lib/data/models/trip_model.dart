import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.destination,
    required super.country,
    required super.startDate,
    required super.endDate,
    super.coverImage,
    super.memberIds,
    super.createdAt,
  });

  factory TripModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return TripModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      title: map['title'] ?? '',
      destination: map['destination'] ?? '',
      country: map['country'] ?? '',
      startDate:
          (map['startDate'] as Timestamp).toDate(),
      endDate:
          (map['endDate'] as Timestamp).toDate(),
      coverImage: map['coverImage'],
      memberIds:
          List<String>.from(map['memberIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'destination': destination,
      'country': country,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'coverImage': coverImage,
      'memberIds': memberIds,
    };
  }
}