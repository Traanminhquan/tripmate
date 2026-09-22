import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/app_user.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen
    extends ConsumerStatefulWidget {
  final AppUser user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<EditProfileScreen>
      createState() =>
          _EditProfileScreenState();
}

class _EditProfileScreenState
    extends ConsumerState<
        EditProfileScreen> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _nameController;

  late final TextEditingController
      _bioController;

  late Set<String>
      _selectedPreferences;

  final List<String>
      _preferences = [
    'Adventure',
    'Food',
    'Culture',
    'Nature',
    'Relaxation',
    'Nightlife',
    'Shopping',
    'Photography',
    'History',
    'Beach',
  ];

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(
      text: widget.user.name,
    );

    _bioController =
        TextEditingController(
      text: widget.user.bio ?? '',
    );

    _selectedPreferences = {
      ...widget.user.travelPreferences,
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    await ref
        .read(
          userControllerProvider.notifier,
        )
        .updateProfile(
          uid: widget.user.id,
          name:
              _nameController.text.trim(),
          bio:
              _bioController.text.trim().isEmpty
                  ? null
                  : _bioController.text.trim(),
          travelPreferences:
              _selectedPreferences
                  .toList(),
        );

    final state =
        ref.read(
      userControllerProvider,
    );

    if (!mounted) {
      return;
    }

    if (state.hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update profile: ${state.error}',
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
  ) {
    final state =
        ref.watch(
      userControllerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
        ),
      ),

      body:
          SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              TextFormField(
                controller:
                    _nameController,
                decoration:
                    const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(
                    Icons
                        .person_outline,
                  ),
                ),
                validator: (
                  value,
                ) {
                  if (value ==
                          null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Please enter your name';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                initialValue:
                    widget.user.email,
                enabled: false,
                decoration:
                    const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(
                    Icons
                        .email_outlined,
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _bioController,
                maxLines: 4,
                maxLength: 200,
                decoration:
                    const InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint:
                      true,
                  prefixIcon: Icon(
                    Icons
                        .notes_outlined,
                  ),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

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

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _preferences.map(
                  (
                    preference,
                  ) {
                    final selected =
                        _selectedPreferences
                            .contains(
                      preference,
                    );

                    return FilterChip(
                      label: Text(
                        preference,
                      ),
                      selected:
                          selected,
                      onSelected: (
                        value,
                      ) {
                        setState(() {
                          if (value) {
                            _selectedPreferences
                                .add(
                              preference,
                            );
                          } else {
                            _selectedPreferences
                                .remove(
                              preference,
                            );
                          }
                        });
                      },
                    );
                  },
                ).toList(),
              ),

              const SizedBox(
                height: 32,
              ),

              ElevatedButton(
                onPressed:
                    state.isLoading
                        ? null
                        : _save,
                child:
                    state.isLoading
                        ? const SizedBox(
                            width:
                                24,
                            height:
                                24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                              color:
                                  Colors
                                      .white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}