import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/trip_activity.dart';
import '../../providers/activity_provider.dart';
import '../../providers/trip_provider.dart';

class TripMapScreen extends ConsumerWidget {
  final String tripId;

  const TripMapScreen({
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
        title: const Text(
          'Trip Map',
        ),
      ),
      body: tripAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (
          error,
          stackTrace,
        ) =>
            Center(
          child: Text(
            'Failed to load trip: $error',
          ),
        ),
        data: (trip) {
          if (trip == null) {
            return const Center(
              child: Text(
                'Trip not found',
              ),
            );
          }

          return activitiesAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (
              error,
              stackTrace,
            ) =>
                Center(
              child: Text(
                'Failed to load activities: $error',
              ),
            ),
            data: (activities) {
              final mappedActivities =
                  activities
                      .where(
                        (activity) =>
                            activity.hasCoordinates,
                      )
                      .toList()
                    ..sort(
                      (a, b) {
                        final dateCompare =
                            a.date.compareTo(
                          b.date,
                        );

                        if (dateCompare != 0) {
                          return dateCompare;
                        }

                        return a.order.compareTo(
                          b.order,
                        );
                      },
                    );

              if (mappedActivities.isEmpty) {
                return _EmptyMap(
                  tripTitle: trip.title,
                );
              }

              final points =
                  mappedActivities
                      .map(
                        (activity) => LatLng(
                          activity.latitude!,
                          activity.longitude!,
                        ),
                      )
                      .toList();

              final bounds =
                  LatLngBounds.fromPoints(
                points,
              );
              
              return Column(
                children: [
                  Expanded(
                    child: FlutterMap(
                      options: mappedActivities.length == 1
                          ? MapOptions(
                              initialCenter:
                                  LatLng(
                                mappedActivities.first.latitude!,
                                mappedActivities.first.longitude!,
                              ),
                              initialZoom: 15,
                            )
                          : MapOptions(
                              initialCameraFit:
                                  CameraFit.bounds(
                                bounds:
                                    LatLngBounds.fromPoints(
                                  points,
                                ),
                                padding:
                                    const EdgeInsets.all(
                                  60,
                                ),
                              ),
                            ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                          // Đổi thành package name thực tế
                          // trong android/app/build.gradle(.kts)
                          userAgentPackageName:
                              'com.example.tripmate',
                        ),

                        MarkerLayer(
                          markers:
                              mappedActivities
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) {
                                      final index =
                                          entry.key;

                                      final activity =
                                          entry.value;

                                      return Marker(
                                        point: LatLng(
                                          activity.latitude!,
                                          activity.longitude!,
                                        ),
                                        width: 48,
                                        height: 48,
                                        child:
                                            GestureDetector(
                                          onTap: () {
                                            _showActivity(
                                              context,
                                              activity,
                                              index + 1,
                                            );
                                          },
                                          child:
                                              _NumberedMarker(
                                            number:
                                                index + 1,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                  .toList(),
                        ),

                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution(
                              'OpenStreetMap contributors',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  _MapSummary(
                    tripTitle:
                        trip.title,
                    activities:
                        mappedActivities,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showActivity(
    BuildContext context,
    TripActivity activity,
    int number,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (
        bottomSheetContext,
      ) {
        return SafeArea(
          
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              24,
            ),
            
            
            child: Column(
              
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  activity.title,
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

                const SizedBox(
                  height: 8,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons
                          .access_time_outlined,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Text(
                      activity
                          .startTime,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Icon(
                      Icons
                          .location_on_outlined,
                      size: 18,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Expanded(
                      child: Text(
                        activity
                            .location,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(
                        bottomSheetContext,
                      ).pop();

                      context.push(
                        '/trips/$tripId/itinerary/${activity.id}',
                      );
                    },
                    icon:
                        const Icon(
                      Icons
                          .open_in_new,
                    ),
                    label:
                        const Text(
                      'View Activity',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapSummary
    extends StatelessWidget {
  final String tripTitle;
  final List<TripActivity>
      activities;

  const _MapSummary({
    required this.tripTitle,
    required this.activities,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      constraints:
          const BoxConstraints(
        maxHeight: 220,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color:
                AppColors.border,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              10,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.map_outlined,
                  color:
                      AppColors.primary,
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        tripTitle,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      Text(
                        '${activities.length} '
                        '${activities.length == 1 ? 'place' : 'places'}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
          ),

          Flexible(
            child:
                ListView.builder(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 4,
              ),
              itemCount:
                  activities.length,
              itemBuilder: (
                context,
                index,
              ) {
                final activity =
                    activities[index];

                return ListTile(
                  dense: true,
                  leading:
                      CircleAvatar(
                    radius: 15,
                    child: Text(
                      '${index + 1}',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    activity.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                  ),
                  subtitle: Text(
                    activity.startTime,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMap
    extends StatelessWidget {
  final String tripTitle;

  const _EmptyMap({
    required this.tripTitle,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons
                  .map_outlined,
              size: 80,
              color: Colors
                  .grey
                  .shade400,
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              tripTitle,
              style:
                  Theme.of(context)
                      .textTheme
                      .titleLarge,
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'No activities with map coordinates yet.\n'
              'Add places from Explore to show them here.',
              textAlign:
                  TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberedMarker
    extends StatelessWidget {
  final int number;

  const _NumberedMarker({
    required this.number,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      alignment:
          Alignment.center,
      children: [
        const Icon(
          Icons.location_on,
          size: 48,
          color:
              AppColors.primary,
        ),

        Positioned(
          top: 7,
          child: Container(
            width: 24,
            height: 24,
            alignment:
                Alignment.center,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape:
                  BoxShape.circle,
            ),
            child: Text(
              '$number',
              style:
                  const TextStyle(
                fontSize: 12,
                fontWeight:
                    FontWeight.bold,
                color:
                    AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}