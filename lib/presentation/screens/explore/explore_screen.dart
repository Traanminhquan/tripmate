import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/place.dart';
import '../../providers/place_provider.dart';
import 'place_detail_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({
    super.key,
  });

  @override
  ConsumerState<ExploreScreen> createState() =>
      _ExploreScreenState();
}

class _ExploreScreenState
    extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  Timer? _debounce;

  String _searchQuery = '';

  Place? _selectedCity;

  String _selectedCategory =
      'tourism.attraction';

  bool _loadingPlaces = false;

  List<Place> _places = [];

  String? _errorMessage;

  final List<_PlaceCategory>
      _categories = const [
    _PlaceCategory(
      label: 'Attractions',
      value: 'tourism.attraction',
      icon: Icons.place_outlined,
    ),
    _PlaceCategory(
      label: 'Food',
      value: 'catering.restaurant',
      icon: Icons.restaurant_outlined,
    ),
    _PlaceCategory(
      label: 'Museums',
      value: 'entertainment.museum',
      icon: Icons.museum_outlined,
    ),
    _PlaceCategory(
      label: 'Hotels',
      value: 'accommodation.hotel',
      icon: Icons.hotel_outlined,
    ),
    _PlaceCategory(
      label: 'Shopping',
      value: 'commercial.shopping_mall',
      icon: Icons.shopping_bag_outlined,
    ),
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  void _onSearchChanged(
    String value,
  ) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(
        milliseconds: 500,
      ),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _searchQuery = value.trim();
        });
      },
    );
  }

  Future<void> _selectCity(
    Place city,
  ) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedCity = city;
      _searchQuery = '';
      _searchController.text =
          city.name;
    });

    await _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    final city = _selectedCity;

    if (city == null) {
      return;
    }

    setState(() {
      _loadingPlaces = true;
      _errorMessage = null;
    });

    try {
      final repository = ref.read(
        placeRepositoryProvider,
      );

      final places =
          await repository.getPlaces(
        latitude: city.latitude,
        longitude: city.longitude,
        category:
            _selectedCategory,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _places = places;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingPlaces = false;
        });
      }
    }
  }

  Future<void> _changeCategory(
    String category,
  ) async {
    if (_selectedCategory ==
        category) {
      return;
    }

    setState(() {
      _selectedCategory =
          category;
    });

    if (_selectedCity != null) {
      await _loadPlaces();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final citySearchAsync =
        ref.watch(
      citySearchProvider(
        _searchQuery,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explore',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadPlaces,
        child: ListView(
          padding:
              const EdgeInsets.all(
            20,
          ),
          children: [
            Text(
              'Discover places',
              style:
                  Theme.of(context)
                      .textTheme
                      .headlineSmall,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Search a city and discover places nearby.',
              style:
                  Theme.of(context)
                      .textTheme
                      .bodyMedium,
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  _searchController,
              onChanged:
                  _onSearchChanged,
              decoration:
                  const InputDecoration(
                hintText:
                    'Search city...',
                prefixIcon: Icon(
                  Icons.search,
                ),
              ),
            ),

            if (_searchQuery.length >=
                2) ...[
              const SizedBox(
                height: 8,
              ),

              citySearchAsync.when(
                loading: () =>
                    const _SearchBox(
                  child: Center(
                    child:
                        Padding(
                      padding:
                          EdgeInsets
                              .all(
                        20,
                      ),
                      child:
                          CircularProgressIndicator(),
                    ),
                  ),
                ),

                error: (
                  error,
                  stackTrace,
                ) =>
                    _SearchBox(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .all(
                      16,
                    ),
                    child: Text(
                      'Search failed: $error',
                    ),
                  ),
                ),

                data: (cities) {
                  if (cities.isEmpty) {
                    return const _SearchBox(
                      child: Padding(
                        padding:
                            EdgeInsets
                                .all(
                          16,
                        ),
                        child: Text(
                          'No cities found.',
                        ),
                      ),
                    );
                  }

                  return _SearchBox(
                    child: Column(
                      children:
                          cities.map(
                        (city) {
                          return ListTile(
                            leading:
                                const Icon(
                              Icons
                                  .location_city_outlined,
                            ),
                            title: Text(
                              city.name,
                            ),
                            subtitle:
                                Text(
                              [
                                city.city,
                                city.country,
                              ]
                                  .where(
                                    (value) =>
                                        value !=
                                            null &&
                                        value!
                                            .isNotEmpty,
                                  )
                                  .join(
                                    ', ',
                                  ),
                            ),
                            onTap: () {
                              _selectCity(
                                city,
                              );
                            },
                          );
                        },
                      ).toList(),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(
              height: 24,
            ),

            Text(
              'Categories',
              style:
                  Theme.of(context)
                      .textTheme
                      .titleLarge,
            ),

            const SizedBox(
              height: 12,
            ),

            SizedBox(
              height: 48,
              child:
                  ListView.separated(
                scrollDirection:
                    Axis.horizontal,
                itemCount:
                    _categories.length,
                separatorBuilder: (
                  context,
                  index,
                ) =>
                    const SizedBox(
                  width: 10,
                ),
                itemBuilder: (
                  context,
                  index,
                ) {
                  final category =
                      _categories[
                          index];

                  final selected =
                      category.value ==
                          _selectedCategory;

                  return ChoiceChip(
                    selected:
                        selected,
                    avatar: Icon(
                      category.icon,
                      size: 18,
                    ),
                    label: Text(
                      category.label,
                    ),
                    onSelected: (_) {
                      _changeCategory(
                        category.value,
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            if (_selectedCity ==
                null)
              const _EmptyExplore()
            else ...[
              Text(
                'Explore in ${_selectedCity!.name}',
                style:
                    Theme.of(context)
                        .textTheme
                        .titleLarge,
              ),

              const SizedBox(
                height: 14,
              ),

              if (_loadingPlaces)
                const Center(
                  child:
                      Padding(
                    padding:
                        EdgeInsets.all(
                      30,
                    ),
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage !=
                  null)
                _ErrorCard(
                  message:
                      _errorMessage!,
                  onRetry:
                      _loadPlaces,
                )
              else if (_places
                  .isEmpty)
                const _NoPlaces()
              else
                ..._places.map(
                  (place) =>
                      _PlaceCard(
                    place: place,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlaceCategory {
  final String label;
  final String value;
  final IconData icon;

  const _PlaceCategory({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _SearchBox
    extends StatelessWidget {
  final Widget child;

  const _SearchBox({
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color:
              AppColors.border,
        ),
      ),
      child: child,
    );
  }
}

class _PlaceCard
    extends StatelessWidget {
  final Place place;

  const _PlaceCard({
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
        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),
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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary
                    .withValues(
                  alpha: 0.1,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: const Icon(
                Icons.place_outlined,
                color:
                    AppColors.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  if (place.address !=
                          null &&
                      place.address!
                          .isNotEmpty)
                    Text(
                      place.address!,
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

class _EmptyExplore
    extends StatelessWidget {
  const _EmptyExplore();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 60,
      ),
      child: Column(
        children: [
          Icon(
            Icons
                .travel_explore_outlined,
            size: 72,
            color: Colors.grey
                .shade400,
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            'Search for a city',
            style:
                Theme.of(context)
                    .textTheme
                    .titleLarge,
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Then choose a category to discover places.',
            textAlign:
                TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NoPlaces
    extends StatelessWidget {
  const _NoPlaces();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Padding(
      padding:
          EdgeInsets.all(30),
      child: Center(
        child: Text(
          'No places found for this category.',
        ),
      ),
    );
  }
}

class _ErrorCard
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
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
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color:
              AppColors.error,
        ),
      ),
      child: Column(
        children: [
          Text(
            message,
          ),

          const SizedBox(
            height: 12,
          ),

          OutlinedButton.icon(
            onPressed:
                onRetry,
            icon: const Icon(
              Icons.refresh,
            ),
            label:
                const Text(
              'Retry',
            ),
          ),
        ],
      ),
    );
  }
}