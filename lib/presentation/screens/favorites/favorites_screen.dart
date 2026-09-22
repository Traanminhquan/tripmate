import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/place.dart';
import '../../providers/favorite_provider.dart';
import '../explore/place_detail_screen.dart';

class FavoritesScreen
    extends ConsumerWidget {
  const FavoritesScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final favoritesAsync =
        ref.watch(
      favoritesProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            favoritesProvider,
          );

          await ref.read(
            favoritesProvider.future,
          );
        },

        child: favoritesAsync.when(
          loading: () =>
              const Center(
            child:
                CircularProgressIndicator(),
          ),

          error: (
            error,
            stackTrace,
          ) =>
              ListView(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(
                  30,
                ),
                child: Center(
                  child: Text(
                    'Failed to load favorites: $error',
                  ),
                ),
              ),
            ],
          ),

          data: (favorites) {
            if (favorites.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(
                    height: 150,
                  ),
                  Icon(
                    Icons
                        .favorite_border,
                    size: 72,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Center(
                    child: Text(
                      'No saved places yet.',
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding:
                  const EdgeInsets.all(
                20,
              ),
              itemCount:
                  favorites.length,

              separatorBuilder:
                  (
                context,
                index,
              ) =>
                      const SizedBox(
                height: 12,
              ),

              itemBuilder:
                  (
                context,
                index,
              ) {
                final place =
                    favorites[index];

                return _FavoriteCard(
                  place: place,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FavoriteCard
    extends StatelessWidget {
  final Place place;

  const _FavoriteCard({
    required this.place,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                PlaceDetailScreen(
              place: place,
            ),
          ),
        );
      },
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
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
            Container(
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(
                color: Colors.red
                    .withOpacity(
                  0.08,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
              ),
              child: const Icon(
                Icons.favorite,
                color: Colors.red,
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
                    place.name,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),

                  if (place.address !=
                          null &&
                      place.address!
                          .isNotEmpty) ...[
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      place.address!,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                    ),
                  ],
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