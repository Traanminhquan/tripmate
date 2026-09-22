import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/trip.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({
    super.key,
  });

  String _formatDate(DateTime date) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Trip? _findUpcomingTrip(
    List<Trip> trips,
  ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final upcoming = trips.where(
      (trip) {
        final endDate = DateTime(
          trip.endDate.year,
          trip.endDate.month,
          trip.endDate.day,
        );

        return !endDate.isBefore(today);
      },
    ).toList()
      ..sort(
        (a, b) => a.startDate.compareTo(
          b.startDate,
        ),
      );

    if (upcoming.isEmpty) {
      return null;
    }

    return upcoming.first;
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final firebaseUser =
        ref.watch(
      firebaseAuthProvider,
    ).currentUser;

    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final profileAsync = ref.watch(
      currentUserProfileProvider(
        firebaseUser.uid,
      ),
    );

    final tripsAsync = ref.watch(
      userTripsProvider,
    );

    final favoritesAsync = ref.watch(
      favoritesProvider,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(
              currentUserProfileProvider(
                firebaseUser.uid,
              ),
            );

            ref.invalidate(
              userTripsProvider,
            );

            ref.invalidate(
              favoritesProvider,
            );

            await Future.wait([
              ref.read(
                currentUserProfileProvider(
                  firebaseUser.uid,
                ).future,
              ),
              ref.read(
                userTripsProvider.future,
              ),
              ref.read(
                favoritesProvider.future,
              ),
            ]);
          },
          child: ListView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            children: [
              profileAsync.when(
                loading: () =>
                    const _HeaderSkeleton(),

                error: (
                  error,
                  stackTrace,
                ) =>
                    Text(
                  'Failed to load profile: $error',
                ),

                data: (profile) {
                  if (profile == null) {
                    return const Text(
                      'Profile not found',
                    );
                  }

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor:
                            AppColors.primary
                                .withValues(
                          alpha: 0.1,
                        ),
                        child:
                            profile.avatarUrl != null &&
                                    profile
                                        .avatarUrl!
                                        .isNotEmpty
                                ? ClipOval(
                                    child:
                                        Image.network(
                                      profile
                                          .avatarUrl!,
                                      width:
                                          52,
                                      height:
                                          52,
                                      fit:
                                          BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    profile.name
                                            .isNotEmpty
                                        ? profile
                                            .name[0]
                                            .toUpperCase()
                                        : '?',
                                    style:
                                        const TextStyle(
                                      fontSize:
                                          20,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color:
                                          AppColors
                                              .primary,
                                    ),
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
                              'Welcome back,',
                              style:
                                  Theme.of(context)
                                      .textTheme
                                      .bodyMedium,
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            Text(
                              profile.name,
                              style:
                                  Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(
                height: 28,
              ),

              Text(
                'Plan your next adventure',
                style:
                    Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                'Create a trip, discover places and build your itinerary.',
                style:
                    Theme.of(context)
                        .textTheme
                        .bodyMedium,
              ),

              const SizedBox(
                height: 20,
              ),

              ElevatedButton.icon(
                onPressed: () {
                  context.push(
                    '/trips/create',
                  );
                },
                icon: const Icon(
                  Icons.add,
                ),
                label: const Text(
                  'Create Trip',
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              Text(
                'Quick Actions',
                style:
                    Theme.of(context)
                        .textTheme
                        .titleLarge,
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _QuickActionCard(
                      icon:
                          Icons.luggage_outlined,
                      title:
                          'My Trips',
                      onTap: () {
                        context.go(
                          '/trips',
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        _QuickActionCard(
                      icon:
                          Icons.travel_explore,
                      title:
                          'Explore',
                      onTap: () {
                        context.go(
                          '/explore',
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        _QuickActionCard(
                      icon:
                          Icons.favorite_outline,
                      title:
                          'Favorites',
                      onTap: () {
                        context.push(
                          '/favorites',
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 28,
              ),

              Text(
                'Your Stats',
                style:
                    Theme.of(context)
                        .textTheme
                        .titleLarge,
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        tripsAsync.when(
                      loading: () =>
                          const _StatCard(
                        title:
                            'Trips',
                        value:
                            '...',
                        icon:
                            Icons
                                .luggage_outlined,
                      ),
                      error: (
                        error,
                        stackTrace,
                      ) =>
                          const _StatCard(
                        title:
                            'Trips',
                        value:
                            '-',
                        icon:
                            Icons
                                .luggage_outlined,
                      ),
                      data: (trips) =>
                          _StatCard(
                        title:
                            'Trips',
                        value:
                            '${trips.length}',
                        icon:
                            Icons
                                .luggage_outlined,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        favoritesAsync.when(
                      loading: () =>
                          const _StatCard(
                        title:
                            'Favorites',
                        value:
                            '...',
                        icon:
                            Icons
                                .favorite_outline,
                      ),
                      error: (
                        error,
                        stackTrace,
                      ) =>
                          const _StatCard(
                        title:
                            'Favorites',
                        value:
                            '-',
                        icon:
                            Icons
                                .favorite_outline,
                      ),
                      data:
                          (favorites) =>
                              _StatCard(
                        title:
                            'Favorites',
                        value:
                            '${favorites.length}',
                        icon:
                            Icons
                                .favorite_outline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 28,
              ),

              Text(
                'Upcoming Trip',
                style:
                    Theme.of(context)
                        .textTheme
                        .titleLarge,
              ),

              const SizedBox(
                height: 12,
              ),

              tripsAsync.when(
                loading: () =>
                    const Center(
                  child:
                      CircularProgressIndicator(),
                ),

                error: (
                  error,
                  stackTrace,
                ) =>
                    Text(
                  'Failed to load trips: $error',
                ),

                data: (trips) {
                  final upcoming =
                      _findUpcomingTrip(
                    trips,
                  );

                  if (upcoming == null) {
                    return _NoUpcomingTrip(
                      onCreate: () {
                        context.push(
                          '/trips/create',
                        );
                      },
                    );
                  }

                  return _UpcomingTripCard(
                    trip:
                        upcoming,
                    startDate:
                        _formatDate(
                      upcoming
                          .startDate,
                    ),
                    endDate:
                        _formatDate(
                      upcoming.endDate,
                    ),
                    onTap: () {
                      context.push(
                        '/trips/${upcoming.id}',
                      );
                    },
                  );
                },
              ),

              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

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
            const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 10,
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
        child: Column(
          children: [
            Icon(
              icon,
              color:
                  AppColors.primary,
              size: 28,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
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
        children: [
          Icon(
            icon,
            color:
                AppColors.primary,
          ),

          const SizedBox(
            width: 12,
          ),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                value,
                style:
                    const TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              Text(
                title,
                style:
                    Theme.of(context)
                        .textTheme
                        .bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingTripCard
    extends StatelessWidget {
  final Trip trip;
  final String startDate;
  final String endDate;
  final VoidCallback onTap;

  const _UpcomingTripCard({
    required this.trip,
    required this.startDate,
    required this.endDate,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(18),
      child: Container(
        padding:
            const EdgeInsets.all(
          18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            18,
          ),
          border: Border.all(
            color:
                AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration:
                  BoxDecoration(
                color:
                    AppColors.primary
                        .withValues(
                  alpha: 0.1,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
              ),
              child: const Icon(
                Icons.flight_takeoff,
                color:
                    AppColors.primary,
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
                    trip.title,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    '${trip.destination}, ${trip.country}',
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    '$startDate - $endDate',
                    style:
                        Theme.of(context)
                            .textTheme
                            .bodySmall,
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

class _NoUpcomingTrip
    extends StatelessWidget {
  final VoidCallback onCreate;

  const _NoUpcomingTrip({
    required this.onCreate,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        24,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flight_outlined,
            size: 48,
            color:
                Colors.grey.shade400,
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            'No upcoming trips',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Create a new trip and start planning your next adventure.',
            textAlign:
                TextAlign.center,
          ),

          const SizedBox(
            height: 16,
          ),

          OutlinedButton(
            onPressed:
                onCreate,
            child:
                const Text(
              'Create Trip',
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSkeleton
    extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 26,
        ),
        SizedBox(
          width: 14,
        ),
        Text(
          'Loading profile...',
        ),
      ],
    );
  }
}