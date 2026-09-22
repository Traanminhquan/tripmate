import '../entities/journal_entry.dart';

abstract class JournalRepository {
  Future<String> createEntry(
    JournalEntry entry,
  );

  Future<List<JournalEntry>>
      getEntries(
    String tripId,
  );

  Future<void> updateEntry(
    JournalEntry entry,
  );

  Future<void> deleteEntry({
    required String tripId,
    required String entryId,
  });
}