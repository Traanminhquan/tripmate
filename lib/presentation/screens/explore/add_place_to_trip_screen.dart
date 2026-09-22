import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/place.dart';
import '../../../domain/entities/trip.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';

class AddPlaceToTripScreen
    extends ConsumerStatefulWidget {
  final Place place;

  const AddPlaceToTripScreen({
    super.key,
    required this.place,
  });

  @override
  ConsumerState<AddPlaceToTripScreen>
      createState() =>
          _AddPlaceToTripScreenState();
}

class _AddPlaceToTripScreenState
    extends ConsumerState<
        AddPlaceToTripScreen> {
  Trip? _selectedTrip;

  DateTime? _selectedDate;

  TimeOfDay _selectedTime =
      const TimeOfDay(
    hour: 9,
    minute: 0,
  );

  Future<void> _selectDate() async {
    final trip = _selectedTrip;

    if (trip == null) {
      return;
    }

    final result =
        await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
              trip.startDate,
      firstDate:
          trip.startDate,
      lastDate:
          trip.endDate,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _selectedDate = result;
    });
  }

  Future<void> _selectTime() async {
    final result =
        await showTimePicker(
      context: context,
      initialTime:
          _selectedTime,
    );

    if (result == null) {
      return;
    }

    setState(() {
      _selectedTime = result;
    });
  }

  String _formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(
    TimeOfDay time,
  ) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _add() async {
    final trip = _selectedTrip;

    if (trip == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a trip.',
          ),
        ),
      );

      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a date.',
          ),
        ),
      );

      return;
    }

    await ref
      .read(
        activityControllerProvider.notifier,
      )
      .createActivity(
        tripId: trip.id,
        title: widget.place.name,
        location:
            widget.place.address ??
                widget.place.name,
        date: _selectedDate!,
        startTime: _formatTime(
          _selectedTime,
        ),

        note: 'Added from Explore',

        latitude:
            widget.place.latitude,

        longitude:
            widget.place.longitude,

        placeId:
            widget.place.id,
      );

    final state = ref.read(
      activityControllerProvider,
    );

    if (!mounted) {
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

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Place added to itinerary.',
        ),
      ),
    );

    context.pop();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final currentUser =
        ref.watch(
      firebaseAuthProvider,
    ).currentUser;

    final activityState =
        ref.watch(
      activityControllerProvider,
    );

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please login first.',
          ),
        ),
      );
    }

    final tripsAsync = ref.watch(
      userTripsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add to Trip',
        ),
      ),

      body: tripsAsync.when(
        loading: () =>
            const Center(
          child:
              CircularProgressIndicator(),
        ),

        error: (
          error,
          stackTrace,
        ) =>
            Center(
          child: Text(
            'Failed to load trips: $error',
          ),
        ),

        data: (trips) {
          if (trips.isEmpty) {
            return const Center(
              child: Text(
                'You do not have any trips yet.',
              ),
            );
          }

          return ListView(
            padding:
                const EdgeInsets.all(
              20,
            ),
            children: [
              Text(
                widget.place.name,
                style:
                    Theme.of(context)
                        .textTheme
                        .headlineSmall,
              ),

              const SizedBox(
                height: 6,
              ),

              if (widget.place.address !=
                  null)
                Text(
                  widget.place.address!,
                ),

              const SizedBox(
                height: 28,
              ),

              DropdownButtonFormField<
                  String>(
                value:
                    _selectedTrip?.id,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Select trip',
                  prefixIcon: Icon(
                    Icons
                        .luggage_outlined,
                  ),
                ),
                items: trips
                    .map(
                      (trip) =>
                          DropdownMenuItem<
                              String>(
                        value:
                            trip.id,
                        child: Text(
                          trip.title,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (
                  tripId,
                ) {
                  if (tripId == null) {
                    return;
                  }

                  final trip =
                      trips.firstWhere(
                    (item) =>
                        item.id ==
                        tripId,
                  );

                  setState(() {
                    _selectedTrip =
                        trip;

                    _selectedDate =
                        trip.startDate;
                  });
                },
              ),

              const SizedBox(
                height: 16,
              ),

              InkWell(
                onTap:
                    _selectedTrip ==
                            null
                        ? null
                        : _selectDate,
                child:
                    InputDecorator(
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Date',
                    prefixIcon: Icon(
                      Icons
                          .calendar_today_outlined,
                    ),
                  ),
                  child: Text(
                    _selectedDate ==
                            null
                        ? 'Select trip first'
                        : _formatDate(
                            _selectedDate!,
                          ),
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              InkWell(
                onTap:
                    _selectTime,
                child:
                    InputDecorator(
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Start time',
                    prefixIcon: Icon(
                      Icons
                          .access_time_outlined,
                    ),
                  ),
                  child: Text(
                    _formatTime(
                      _selectedTime,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              ElevatedButton.icon(
                onPressed:
                    activityState
                            .isLoading
                        ? null
                        : _add,
                icon:
                    activityState
                            .isLoading
                        ? const SizedBox(
                            width:
                                20,
                            height:
                                20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                              color:
                                  Colors
                                      .white,
                            ),
                          )
                        : const Icon(
                            Icons.add,
                          ),
                label:
                    const Text(
                  'Add to Itinerary',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}