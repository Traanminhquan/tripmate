import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/trip_activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/trip_provider.dart';

class ItineraryScreen extends ConsumerWidget {
  final String tripId;

  const ItineraryScreen({
    super.key,
    required this.tripId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final tripAsync = ref.watch(
      tripByIdProvider(tripId),
    );

    final activitiesAsync = ref.watch(
      activitiesProvider(tripId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary'),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          context.push(
            '/trips/$tripId/itinerary/create',
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Activity'),
      ),
      body: tripAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Failed to load trip: $error',
          ),
        ),
        data: (trip) {
          if (trip == null) {
            return const Center(
              child: Text('Trip not found'),
            );
          }

          return activitiesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) =>
                Center(
              child: Text(
                'Failed to load itinerary: $error',
              ),
            ),
            data: (activities) {
              return ListView(
                padding:
                    const EdgeInsets.all(20),
                children: [
                  Text(
                    trip.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${trip.destination}, ${trip.country}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  ..._buildDays(
                    context,
                    trip.startDate,
                    trip.endDate,
                    activities,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildDays(
    BuildContext context,
    DateTime startDate,
    DateTime endDate,
    List<TripActivity> activities,
  ) {
    final widgets = <Widget>[];

    var current = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    var dayNumber = 1;

    while (!current.isAfter(end)) {
      final dayActivities = activities
          .where(
            (activity) =>
                _sameDate(
              activity.date,
              current,
            ),
          )
          .toList();

      widgets.add(
        _DaySection(
          dayNumber: dayNumber,
          date: current,
          activities: dayActivities,
        ),
      );

      widgets.add(
        const SizedBox(height: 20),
      );

      current = current.add(
        const Duration(days: 1),
      );

      dayNumber++;
    }

    return widgets;
  }

  bool _sameDate(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _DaySection extends StatelessWidget {
  final int dayNumber;
  final DateTime date;
  final List<TripActivity> activities;

  const _DaySection({
    required this.dayNumber,
    required this.date,
    required this.activities,
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
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          'Day $dayNumber',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          _formatDate(date),
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
        ),

        const SizedBox(height: 12),

        if (activities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.border,
              ),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: const Text(
              'No activities planned.',
            ),
          )
        else
          ...activities.map(
            (activity) =>
                _ActivityCard(
              activity: activity,
            ),
          ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final TripActivity activity;

  const _ActivityCard({
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
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
          SizedBox(
            width: 56,
            child: Text(
              activity.startTime,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color:
                          AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity.location,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                    ),
                  ],
                ),

                if (activity.note != null &&
                    activity.note!
                        .trim()
                        .isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    activity.note!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}