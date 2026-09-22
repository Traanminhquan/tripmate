import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/journal_entry.dart';
import '../../providers/journal_provider.dart';

class JournalDetailScreen
    extends ConsumerWidget {
  final JournalEntry entry;

  const JournalDetailScreen({
    super.key,
    required this.entry,
  });

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _moodEmoji(
    String mood,
  ) {
    switch (mood) {
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

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          title: const Text(
            'Delete journal entry?',
          ),
          content: const Text(
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color:
                      AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(
          journalControllerProvider
              .notifier,
        )
        .deleteEntry(
          tripId:
              entry.tripId,
          entryId:
              entry.id,
        );

    final state =
        ref.read(
      journalControllerProvider,
    );

    if (!context.mounted) {
      return;
    }

    if (state.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            state.error.toString(),
          ),
        ),
      );

      return;
    }

    context.pop();
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state =
        ref.watch(
      journalControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Journal Entry',
        ),
        actions: [
          IconButton(
            onPressed:
                state.isLoading
                    ? null
                    : () {
                        context.push(
                          '/trips/${entry.tripId}/journal/${entry.id}/edit',
                          extra: entry,
                        );
                      },
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),

          IconButton(
            onPressed:
                state.isLoading
                    ? null
                    : () {
                        _delete(
                          context,
                          ref,
                        );
                      },
            icon: const Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(
          20,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                20,
              ),
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.08,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  20,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _moodEmoji(
                      entry.mood,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 52,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    entry.mood,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Text(
              entry.title,
              style:
                  Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [
                const Icon(
                  Icons
                      .calendar_today_outlined,
                  size: 18,
                ),

                const SizedBox(
                  width: 8,
                ),

                Text(
                  _formatDate(
                    entry.date,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 24,
            ),

            Text(
              'Memory',
              style:
                  Theme.of(context)
                      .textTheme
                      .titleLarge,
            ),

            const SizedBox(
              height: 12,
            ),

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                18,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.white,
                borderRadius:
                    BorderRadius
                        .circular(
                  16,
                ),
                border:
                    Border.all(
                  color:
                      AppColors.border,
                ),
              ),
              child: Text(
                entry.content,
                style:
                    const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}