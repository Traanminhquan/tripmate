import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen
    extends ConsumerWidget {
  const ProfileScreen({
    super.key,
  });

  Future<void> _logout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await ref
        .read(
          authControllerProvider.notifier,
        )
        .logout();

    final state =
        ref.read(
      authControllerProvider,
    );

    if (!context.mounted) {
      return;
    }

    if (state.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Logout failed',
          ),
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

    final profileAsync =
        ref.watch(
      currentUserProfileProvider(
        firebaseUser.uid,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
        ),
      ),

      body: profileAsync.when(
        loading: () => const Center(
          child:
              CircularProgressIndicator(),
        ),

        error: (
          error,
          stackTrace,
        ) =>
            Center(
          child: Text(
            'Failed to load profile: $error',
          ),
        ),

        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text(
                'Profile not found',
              ),
            );
          }

          return ListView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor:
                      AppColors.primary
                          .withValues(
                    alpha: 0.1,
                  ),
                  child:
                      profile.avatarUrl !=
                                  null &&
                              profile
                                  .avatarUrl!
                                  .isNotEmpty
                          ? ClipOval(
                              child:
                                  Image.network(
                                profile
                                    .avatarUrl!,
                                width: 104,
                                height: 104,
                                fit: BoxFit
                                    .cover,
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
                                    36,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color:
                                    AppColors
                                        .primary,
                              ),
                            ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              Center(
                child: Text(
                  profile.name,
                  style:
                      Theme.of(context)
                          .textTheme
                          .headlineMedium,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Center(
                child: Text(
                  profile.email,
                  style:
                      Theme.of(context)
                          .textTheme
                          .bodyMedium,
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              _ProfileCard(
                icon:
                    Icons.person_outline,
                title: 'Edit Profile',
                subtitle:
                    'Update your personal information',
                onTap: () {
                  context.push(
                    '/profile/edit',
                    extra: profile,
                  );
                },
              ),

              const SizedBox(
                height: 12,
              ),

              _InfoSection(
                title: 'Bio',
                value:
                    profile.bio == null ||
                            profile.bio!
                                .trim()
                                .isEmpty
                        ? 'No bio added yet.'
                        : profile.bio!,
              ),

              const SizedBox(
                height: 12,
              ),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
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
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Travel Preferences',
                      style:
                          Theme.of(context)
                              .textTheme
                              .titleLarge,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    if (profile
                        .travelPreferences
                        .isEmpty)
                      Text(
                        'No preferences selected.',
                        style:
                            Theme.of(context)
                                .textTheme
                                .bodyMedium,
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: profile
                            .travelPreferences
                            .map(
                              (
                                preference,
                              ) =>
                                  Chip(
                                label:
                                    Text(
                                  preference,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              OutlinedButton.icon(
                onPressed: () {
                  _logout(
                    context,
                    ref,
                  );
                },
                icon: const Icon(
                  Icons.logout,
                ),
                label: const Text(
                  'Logout',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
            const EdgeInsets.all(16),
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
              color:
                  AppColors.primary,
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
                    title,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    subtitle,
                    style:
                        Theme.of(context)
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

class _InfoSection
    extends StatelessWidget {
  final String title;
  final String value;

  const _InfoSection({
    required this.title,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                Theme.of(context)
                    .textTheme
                    .titleLarge,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            value,
            style:
                Theme.of(context)
                    .textTheme
                    .bodyMedium,
          ),
        ],
      ),
    );
  }
}