import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/trip.dart';
import '../../providers/trip_provider.dart';
import 'package:go_router/go_router.dart';

class TripDetailScreen extends ConsumerWidget {
  Future<void> _deleteTrip(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete trip?'),
          content: const Text(
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true);
              },
              child: const Text(
                'Delete',
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
        .read(tripControllerProvider.notifier)
        .deleteTrip(tripId);

    final state =
        ref.read(tripControllerProvider);

    if (!context.mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete trip: ${state.error}',
          ),
        ),
      );

      return;
    }

    ref.invalidate(
      tripByIdProvider(tripId),
    );

    Navigator.of(context).pop();
  }

  final String tripId;

  const TripDetailScreen({
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

    final tripControllerState = ref.watch(
      tripControllerProvider,
    );

    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),

      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          title: const Text('Trip Details'),
        ),
        body: Center(
          child: Text(
            'Failed to load trip: $error',
          ),
        ),
      ),

      data: (trip) {
        if (trip == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Trip Details',
              ),
            ),
            body: const Center(
              child: Text(
                'Trip not found',
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Trip Details',
            ),
            actions: [
              IconButton(
                onPressed:
                    tripControllerState.isLoading
                        ? null
                        : () {
                            context.push(
                              '/trips/$tripId/edit',
                              extra: trip,
                            );
                          },
                icon: const Icon(
                  Icons.edit_outlined,
                ),
              ),

              IconButton(
                onPressed:
                    tripControllerState.isLoading
                        ? null
                        : () {
                            _deleteTrip(
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
          body: tripControllerState.isLoading
              ? Stack(
                  children: [
                    _TripDetailContent(
                      trip: trip,
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
              : _TripDetailContent(
                  trip: trip,
                ),
        );
      },
    );
  }
}

class _TripDetailContent extends StatelessWidget {
  final Trip trip;

  const _TripDetailContent({
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
                  Icons.flight_takeoff,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 16),
                Text(
                  trip.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${trip.destination}, ${trip.country}',
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
            title: 'Travel dates',
            value:
                '${_formatDate(trip.startDate)} - ${_formatDate(trip.endDate)}',
          ),

          const SizedBox(height: 12),

          _InfoCard(
            icon: Icons.schedule_outlined,
            title: 'Duration',
            value:
                '${trip.durationInDays} days',
          ),

          const SizedBox(height: 28),

          Text(
            'Trip Tools',
            style: Theme.of(context)
                .textTheme
                .titleLarge,
          ),

          const SizedBox(height: 14),

          _ToolCard(
            icon: Icons.route_outlined,
            title: 'Itinerary',
            subtitle: 'Plan activities for each day',
            onTap: () {
              context.push(
                '/trips/${trip.id}/itinerary',
              );
            },
          ),

          const SizedBox(height: 12),

          _ToolCard(
            icon: Icons.attach_money,
            title: 'Expenses',
            subtitle:
                'Track your travel spending',
            onTap: () {},
          ),

          const SizedBox(height: 12),

          _ToolCard(
            icon: Icons.group_outlined,
            title: 'Members',
            subtitle:
                'Manage trip members',
            onTap: () {},
          ),

          const SizedBox(height: 12),

          _ToolCard(
            icon: Icons.menu_book_outlined,
            title: 'Journal',
            subtitle:
                'Save memories from your trip',
            onTap: () {},
          ),
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
                    fontWeight: FontWeight.w600,
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

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
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
                    title,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium,
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