import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/app_user.dart';
import '../../../domain/entities/trip.dart';
import '../../providers/trip_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';

class MembersScreen extends ConsumerWidget {
  final String tripId;

  const MembersScreen({
    super.key,
    required this.tripId,
  });

  String _cleanErrorMessage(
    Object? error,
  ) {
    if (error == null) {
      return 'Something went wrong.';
    }

    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }

  Future<void> _showAddMemberDialog(
    BuildContext context,
    WidgetRef ref,
    Trip trip,
  ) async {
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String emailValue = '';

        return AlertDialog(
          title: const Text(
            'Add Member',
          ),

          content: TextField(
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'friend@example.com',
              prefixIcon: Icon(
                Icons.email_outlined,
              ),
            ),
            onChanged: (value) {
              emailValue = value;
            },
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                final value =
                    emailValue.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(
                  value,
                );
              },
              child: const Text(
                'Add',
              ),
            ),
          ],
        );
      },
    );

    if (email == null ||
        email.trim().isEmpty) {
      return;
    }

    await ref
        .read(
          tripControllerProvider.notifier,
        )
        .addMember(
          trip: trip,
          email: email.trim(),
        );

    final state =
        ref.read(tripControllerProvider);

    if (!context.mounted) {
      return;
    }

    if (state.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _cleanErrorMessage(
              state.error,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Member added successfully.',
        ),
      ),
    );
  }

  Future<void> _removeMember(
    BuildContext context,
    WidgetRef ref,
    Trip trip,
    AppUser member,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove member?',
          ),
          content: Text(
            'Remove ${member.name} from this trip?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child:
                  const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Remove',
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
          tripControllerProvider.notifier,
        )
        .removeMember(
          trip: trip,
          userId: member.id,
        );

    final state =
        ref.read(tripControllerProvider);

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
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final tripAsync = ref.watch(
      tripByIdProvider(tripId),
    );

    final controllerState = ref.watch(
      tripControllerProvider,
    );

    final currentUser =
      ref.watch(firebaseAuthProvider).currentUser;
    
    return tripAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      ),

      error: (
        error,
        stackTrace,
      ) =>
          Scaffold(
        appBar: AppBar(
          title: const Text(
            'Trip Members',
          ),
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
                'Trip Members',
              ),
            ),
            body: const Center(
              child: Text(
                'Trip not found',
              ),
            ),
          );
        }
        
        final isOwner =
            currentUser?.uid == trip.ownerId;
        
        final membersAsync =
            ref.watch(
          tripMembersProvider(
            trip.memberIds,
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Trip Members',
            ),
            actions: [
              if (isOwner)
                IconButton(
                  onPressed: controllerState.isLoading
                      ? null
                      : () {
                          _showAddMemberDialog(
                            context,
                            ref,
                            trip,
                          );
                        },
                  icon: const Icon(
                    Icons.person_add_outlined,
                  ),
                ),
            ],
          ),

          body: membersAsync.when(
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
                'Failed to load members: $error',
              ),
            ),

            data: (members) {
              return ListView.separated(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                itemCount:
                    members.length,
                separatorBuilder:
                    (
                  context,
                  index,
                ) =>
                        const Divider(),
                itemBuilder:
                    (
                  context,
                  index,
                ) {
                  final member =
                      members[index];

                  final isOwnerMember =
                      member.id == trip.ownerId;

                  return ListTile(
                    leading:
                        CircleAvatar(
                      child: Text(
                        member.name
                                .isNotEmpty
                            ? member
                                .name[0]
                                .toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      member.name,
                    ),
                    subtitle: Text(
                      member.email,
                    ),
                    trailing: isOwnerMember
                        ? const Chip(
                            label: Text('Owner'),
                          )
                        : isOwner
                            ? IconButton(
                                onPressed:
                                    controllerState.isLoading
                                        ? null
                                        : () {
                                            _removeMember(
                                              context,
                                              ref,
                                              trip,
                                              member,
                                            );
                                          },
                                icon: const Icon(
                                  Icons.person_remove_outlined,
                                ),
                              )
                            : null,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}