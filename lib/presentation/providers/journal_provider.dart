import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/journal_remote_datasource.dart';
import '../../data/repositories/journal_repository_impl.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import 'user_provider.dart';

final journalRemoteDataSourceProvider =
    Provider<JournalRemoteDataSource>(
  (ref) {
    return JournalRemoteDataSource(
      firestore:
          ref.read(firestoreProvider),
    );
  },
);

final journalRepositoryProvider =
    Provider<JournalRepository>(
  (ref) {
    return JournalRepositoryImpl(
      remoteDataSource: ref.read(
        journalRemoteDataSourceProvider,
      ),
    );
  },
);

final journalEntriesProvider =
    FutureProvider.family<
        List<JournalEntry>,
        String>(
  (ref, tripId) {
    return ref
        .read(journalRepositoryProvider)
        .getEntries(tripId);
  },
);

class JournalController
    extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createEntry({
    required String tripId,
    required String title,
    required String content,
    required DateTime date,
    required String mood,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () async {
        final entry =
            JournalEntry(
          id: '',
          tripId: tripId,
          title: title,
          content: content,
          date: date,
          mood: mood,
        );

        await ref
            .read(
              journalRepositoryProvider,
            )
            .createEntry(entry);

        ref.invalidate(
          journalEntriesProvider(
            tripId,
          ),
        );
      },
    );
  }

  Future<void> updateEntry({
    required JournalEntry entry,
    required String title,
    required String content,
    required DateTime date,
    required String mood,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () async {
        final updated =
            JournalEntry(
          id: entry.id,
          tripId: entry.tripId,
          title: title,
          content: content,
          date: date,
          mood: mood,
          createdAt:
              entry.createdAt,
        );

        await ref
            .read(
              journalRepositoryProvider,
            )
            .updateEntry(updated);

        ref.invalidate(
          journalEntriesProvider(
            entry.tripId,
          ),
        );
      },
    );
  }

  Future<void> deleteEntry({
    required String tripId,
    required String entryId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () async {
        await ref
            .read(
              journalRepositoryProvider,
            )
            .deleteEntry(
              tripId: tripId,
              entryId: entryId,
            );

        ref.invalidate(
          journalEntriesProvider(
            tripId,
          ),
        );
      },
    );
  }
}

final journalControllerProvider =
    AsyncNotifierProvider<
        JournalController,
        void>(
  JournalController.new,
);