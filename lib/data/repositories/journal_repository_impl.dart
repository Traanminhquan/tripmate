import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/journal_remote_datasource.dart';
import '../models/journal_entry_model.dart';

class JournalRepositoryImpl
    implements JournalRepository {
  final JournalRemoteDataSource
      remoteDataSource;

  JournalRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<String> createEntry(
    JournalEntry entry,
  ) {
    final model =
        JournalEntryModel(
      id: entry.id,
      tripId: entry.tripId,
      title: entry.title,
      content: entry.content,
      date: entry.date,
      mood: entry.mood,
      createdAt:
          entry.createdAt,
    );

    return remoteDataSource
        .createEntry(model);
  }

  @override
  Future<List<JournalEntry>>
      getEntries(
    String tripId,
  ) {
    return remoteDataSource
        .getEntries(tripId);
  }

  @override
  Future<void> updateEntry(
    JournalEntry entry,
  ) {
    final model =
        JournalEntryModel(
      id: entry.id,
      tripId: entry.tripId,
      title: entry.title,
      content: entry.content,
      date: entry.date,
      mood: entry.mood,
      createdAt:
          entry.createdAt,
    );

    return remoteDataSource
        .updateEntry(model);
  }

  @override
  Future<void> deleteEntry({
    required String tripId,
    required String entryId,
  }) {
    return remoteDataSource
        .deleteEntry(
      tripId: tripId,
      entryId: entryId,
    );
  }
}