import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/trip.dart';
import '../../providers/trip_provider.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final tripsAsync =
        ref.watch(userTripsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          context.push('/trips/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Trip'),
      ),

      body: tripsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Unable to load trips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                      userTripsProvider,
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),

        data: (trips) {
          if (trips.isEmpty) {
            return _EmptyTrips(
              onCreate: () {
                context.push(
                  '/trips/create',
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                userTripsProvider,
              );

              await ref.read(
                userTripsProvider.future,
              );
            },
            child: ListView.separated(
              padding:
                  const EdgeInsets.all(20),
              itemCount: trips.length,
              separatorBuilder:
                  (context, index) =>
                      const SizedBox(
                height: 12,
              ),
              itemBuilder:
                  (context, index) {
                return _TripCard(
                  trip: trips[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyTrips extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyTrips({
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.luggage_outlined,
              size: 72,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              'No trips yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first trip and start building your itinerary.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text(
                'Create your first trip',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;

  const _TripCard({
    required this.trip,
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
    return InkWell(
      onTap: () {
        // Trip detail sẽ làm ở bước tiếp theo.
      },
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
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
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(
                  alpha: 0.1,
                ),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.flight_takeoff,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${trip.destination}, ${trip.country}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .calendar_today_outlined,
                        size: 16,
                        color: AppColors
                            .textSecondary,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}',
                          style:
                              Theme.of(context)
                                  .textTheme
                                  .bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '${trip.durationInDays} days',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}