import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/journal_entry.dart';
import '../../providers/journal_provider.dart';

class JournalScreen
    extends ConsumerWidget {
  final String tripId;

  const JournalScreen({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final entriesAsync =
        ref.watch(
      journalEntriesProvider(
        tripId,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Travel Journal',
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          context.push(
            '/trips/$tripId/journal/create',
          );
        },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'New Entry',
        ),
      ),

      body: entriesAsync.when(
        loading: () =>
            const Center(
          child:
              CircularProgressIndicator(),
        ),

        error: (
          error,
          stackTrace,
        ) =>
            Center(
          child: Text(
            'Failed to load journal: $error',
          ),
        ),

        data: (entries) {
          if (entries.isEmpty) {
            return const _EmptyJournal();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                journalEntriesProvider(
                  tripId,
                ),
              );

              await ref.read(
                journalEntriesProvider(
                  tripId,
                ).future,
              );
            },
            child: ListView.separated(
              padding:
                  const EdgeInsets.all(
                20,
              ),
              itemCount:
                  entries.length,
              separatorBuilder:
                  (
                context,
                index,
              ) =>
                      const SizedBox(
                height: 12,
              ),
              itemBuilder:
                  (
                context,
                index,
              ) {
                return _JournalCard(
                  entry:
                      entries[index],
                  onTap: () {
                    context.push(
                      '/trips/$tripId/journal/${entries[index].id}',
                      extra:
                          entries[index],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _JournalCard
    extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;

  const _JournalCard({
    required this.entry,
    required this.onTap,
  });

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _moodEmoji() {
    switch (entry.mood) {
      case 'Excited':
        return '🤩';
      case 'Happy':
        return '😊';
      case 'Relaxed':
        return '😌';
      case 'Tired':
        return '😴';
      case 'Sad':
        return '😢';
      default:
        return '🙂';
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
        padding:
            const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          border: Border.all(
            color:
                AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              _moodEmoji(),
              style:
                  const TextStyle(
                fontSize: 32,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    entry.title,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    _formatDate(
                      entry.date,
                    ),
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodySmall,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    entry.content,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyJournal
    extends StatelessWidget {
  const _EmptyJournal();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 80,
              color: Colors
                  .grey
                  .shade400,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              'No journal entries yet',
              style:
                  Theme.of(context)
                      .textTheme
                      .titleLarge,
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Save your memories and feelings from this trip.',
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}