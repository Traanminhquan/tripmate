import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/place.dart';
import 'add_place_to_trip_screen.dart';

class PlaceDetailScreen extends ConsumerWidget {
  final Place place;

  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Place Detail',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(20),
              color: AppColors.primary
                  .withValues(
                alpha: 0.08,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.place_outlined,
                size: 72,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            place.name,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          if (place.address != null &&
              place.address!.isNotEmpty)
            Text(
              place.address!,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge,
            ),

          const SizedBox(height: 24),

          _InfoCard(
            icon: Icons.location_on_outlined,
            title: 'Location',
            value:
                '${place.latitude.toStringAsFixed(5)}, '
                '${place.longitude.toStringAsFixed(5)}',
          ),

          if (place.city != null &&
              place.city!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.location_city_outlined,
              title: 'City',
              value: place.city!,
            ),
          ],

          if (place.country != null &&
              place.country!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.public_outlined,
              title: 'Country',
              value: place.country!,
            ),
          ],

          if (place.categories.isNotEmpty) ...[
            const SizedBox(height: 24),

            Text(
              'Categories',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: place.categories
                  .take(6)
                  .map(
                    (category) => Chip(
                      label: Text(
                        _formatCategory(
                          category,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: 32),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AddPlaceToTripScreen(
                    place: place,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.add_location_alt_outlined,
            ),
            label: const Text(
              'Add to Trip',
            ),
          ),
        ],
      ),
    );
  }

  String _formatCategory(
    String category,
  ) {
    final value = category
        .split('.')
        .last
        .replaceAll('_', ' ');

    if (value.isEmpty) {
      return category;
    }

    return value[0].toUpperCase() +
        value.substring(1);
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
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
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
                      .bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w600,
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