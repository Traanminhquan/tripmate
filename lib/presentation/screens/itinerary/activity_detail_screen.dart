import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/trip_activity.dart';
import '../../providers/activity_provider.dart';

class ActivityDetailScreen extends ConsumerWidget {
  final String tripId;
  final String activityId;

  const ActivityDetailScreen({
    super.key,
    required this.tripId,
    required this.activityId,
  });

  Future<void> _deleteActivity(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete activity?'),
          content: const Text(
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.error,
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
        .read(activityControllerProvider.notifier)
        .deleteActivity(
          tripId: tripId,
          activityId: activityId,
        );

    final state =
        ref.read(activityControllerProvider);

    if (!context.mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete activity: ${state.error}',
          ),
        ),
      );

      return;
    }

    ref.invalidate(
      activitiesProvider(tripId),
    );

    context.pop();
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final activityAsync = ref.watch(
      activityByIdProvider(
        (
          tripId: tripId,
          activityId: activityId,
        ),
      ),
    );

    final controllerState = ref.watch(
      activityControllerProvider,
    );

    return activityAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),

      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: const Text('Activity'),
        ),
        body: Center(
          child: Text(
            'Failed to load activity: $error',
          ),
        ),
      ),

      data: (activity) {
        if (activity == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Activity'),
            ),
            body: const Center(
              child: Text(
                'Activity not found',
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Activity Details'),
            actions: [
              IconButton(
                onPressed: controllerState.isLoading
                    ? null
                    : () {
                        context.push(
                          '/trips/$tripId/itinerary/$activityId/edit',
                          extra: activity,
                        );
                      },
                icon: const Icon(
                  Icons.edit_outlined,
                ),
              ),
              IconButton(
                onPressed: controllerState.isLoading
                    ? null
                    : () {
                        _deleteActivity(
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
          body: controllerState.isLoading
              ? Stack(
                  children: [
                    _ActivityContent(
                      activity: activity,
                    ),
                    Container(
                      color: Colors.black12,
                      child: const Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    ),
                  ],
                )
              : _ActivityContent(
                  activity: activity,
                ),
        );
      },
    );
  }
}

class _ActivityContent extends StatelessWidget {
  final TripActivity activity;

  const _ActivityContent({
    required this.activity,
  });

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 16),
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  activity.location,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _InfoCard(
            icon: Icons.calendar_today_outlined,
            title: 'Date',
            value: _formatDate(
              activity.date,
            ),
          ),

          const SizedBox(height: 12),

          _InfoCard(
            icon: Icons.access_time,
            title: 'Time',
            value: activity.startTime,
          ),

          const SizedBox(height: 12),

          _InfoCard(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value: activity.location,
          ),

          if (activity.note != null &&
              activity.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),

            _InfoCard(
              icon: Icons.notes_outlined,
              title: 'Note',
              value: activity.note!,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}