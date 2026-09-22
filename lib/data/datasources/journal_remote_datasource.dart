import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/journal_entry_model.dart';

class JournalRemoteDataSource {
  final FirebaseFirestore firestore;

  JournalRemoteDataSource({
    required this.firestore,
  });

  CollectionReference<
      Map<String, dynamic>> _ref(
    String tripId,
  ) {
    return firestore
        .collection('trips')
        .doc(tripId)
        .collection('journal');
  }

  Future<String> createEntry(
    JournalEntryModel entry,
  ) async {
    final doc =
        _ref(entry.tripId).doc();

    await doc.set({
      ...entry.toMap(),
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<List<JournalEntryModel>>
      getEntries(
    String tripId,
  ) async {
    final snapshot =
        await _ref(tripId)
            .orderBy(
              'date',
              descending: true,
            )
            .get();

    return snapshot.docs.map(
      (doc) {
        return JournalEntryModel.fromMap(
          id: doc.id,
          tripId: tripId,
          map: doc.data(),
        );
      },
    ).toList();
  }

  Future<void> updateEntry(
    JournalEntryModel entry,
  ) async {
    await _ref(entry.tripId)
        .doc(entry.id)
        .update(
          entry.toMap(),
        );
  }

  Future<void> deleteEntry({
    required String tripId,
    required String entryId,
  }) async {
    await _ref(tripId)
        .doc(entryId)
        .delete();
  }
}