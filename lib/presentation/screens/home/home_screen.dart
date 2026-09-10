import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    final state =
        ref.read(authControllerProvider);

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
    final authState = ref.watch(authControllerProvider);

    final firebaseUser =
      ref.watch(firebaseAuthProvider).currentUser;
    
    final profileAsync = firebaseUser == null
      ? null
      : ref.watch(
          currentUserProfileProvider(firebaseUser.uid),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('TripMate'),
        actions: [
          IconButton(
            onPressed: authState.isLoading
                ? null
                : () => _logout(context, ref),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: firebaseUser == null
        ? const Center(
            child: Text('No user'),
          )
        : profileAsync!.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),

            error: (error, stackTrace) => Center(
              child: Text(
                'Error: $error',
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

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${profile.name}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium,
                    ),

                    const SizedBox(height: 8),

                    Text(profile.email),
                  ],
                ),
              );
            },
          ),
    );
  }
}