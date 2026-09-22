import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/journal_entry.dart';

class JournalEntryModel extends JournalEntry {
  const JournalEntryModel({
    required super.id,
    required super.tripId,
    required super.title,
    required super.content,
    required super.date,
    required super.mood,
    super.createdAt,
  });

  factory JournalEntryModel.fromMap({
    required String id,
    required String tripId,
    required Map<String, dynamic> map,
  }) {
    return JournalEntryModel(
      id: id,
      tripId: tripId,
      title:
          map['title']?.toString() ?? '',
      content:
          map['content']?.toString() ?? '',
      date:
          (map['date'] as Timestamp)
              .toDate(),
      mood:
          map['mood']?.toString() ??
              'Happy',
      createdAt:
          (map['createdAt']
                  as Timestamp?)
              ?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date':
          Timestamp.fromDate(date),
      'mood': mood,
    };
  }
}