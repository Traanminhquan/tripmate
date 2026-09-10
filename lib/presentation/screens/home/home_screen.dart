import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref
        .read(authControllerProvider.notifier)
        .logout();

    final state = ref.read(authControllerProvider);

    if (!context.mounted) return;

    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed'),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final firebaseUser =
        ref.watch(firebaseAuthProvider).currentUser;

    if (firebaseUser == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final profileAsync = ref.watch(
      currentUserProfileProvider(firebaseUser.uid),
    );

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Failed to load profile: $error',
            ),
          ),
          data: (profile) {
            if (profile == null) {
              return const Center(
                child: Text('Profile not found'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(
                  currentUserProfileProvider(firebaseUser.uid),
                );
              },
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              AppColors.primary
                                  .withValues(alpha: 0.1),
                          child: Text(
                            profile.name.isNotEmpty
                                ? profile.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
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
                                'Welcome back,',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                              Text(
                                profile.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _logout(context, ref);
                          },
                          icon: const Icon(
                            Icons.logout,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                            size: 32,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Plan your next adventure',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create a trip and build your itinerary step by step.',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton(
                            onPressed: () {
                              context.go('/trips');
                            },
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.white,
                              foregroundColor:
                                  AppColors.primary,
                              minimumSize:
                                  const Size(
                                double.infinity,
                                48,
                              ),
                            ),
                            child: const Text(
                              'Create a Trip',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Quick Actions',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.luggage_outlined,
                            title: 'My Trips',
                            onTap: () {
                              context.go('/trips');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon:
                                Icons.explore_outlined,
                            title: 'Explore',
                            onTap: () {
                              context.go('/explore');
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Trips',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/trips');
                          },
                          child: const Text('View all'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const _TripPreviewCard(
                      city: 'Tokyo',
                      country: 'Japan',
                      date: '12 Sep - 18 Sep',
                      days: '7 days',
                      icon: Icons.location_city,
                    ),

                    const SizedBox(height: 12),

                    const _TripPreviewCard(
                      city: 'Bangkok',
                      country: 'Thailand',
                      date: '05 Oct - 09 Oct',
                      days: '5 days',
                      icon: Icons.temple_buddhist,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripPreviewCard extends StatelessWidget {
  final String city;
  final String country;
  final String date;
  final String days;
  final IconData icon;

  const _TripPreviewCard({
    required this.city,
    required this.country,
    required this.date,
    required this.days,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
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
                  '$city, $country',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            days,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}