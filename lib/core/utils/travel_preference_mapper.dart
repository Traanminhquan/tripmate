class TravelPreferenceMapper {
  static List<String> toCategories(
    List<String> preferences,
  ) {
    final categories = <String>{};

    for (final preference in preferences) {
      switch (preference.toLowerCase()) {
        case 'food':
          categories.add(
            'catering.restaurant',
          );
          break;

        case 'culture':
          categories.add(
            'tourism.sights',
          );
          categories.add(
            'entertainment.museum',
          );
          break;

        case 'nature':
          categories.add(
            'leisure.park',
          );
          categories.add(
            'tourism.attraction.viewpoint',
          );
          break;

        case 'history':
          categories.add(
            'tourism.sights',
          );
          categories.add(
            'entertainment.museum',
          );
          break;

        case 'shopping':
          categories.add(
            'commercial.shopping_mall',
          );
          break;

        case 'nightlife':
          categories.add(
            'catering.bar',
          );
          break;

        case 'beach':
          categories.add(
            'tourism',
          );
          break;

        case 'photography':
          categories.add(
            'tourism.attraction',
          );
          categories.add(
            'tourism.attraction.viewpoint',
          );
          break;

        case 'adventure':
          categories.add(
            'tourism.attraction',
          );
          break;

        case 'relaxation':
          categories.add(
            'leisure.park',
          );
          break;

        default:
          categories.add(
            'tourism.attraction',
          );
      }
    }

    if (categories.isEmpty) {
      categories.addAll([
        'tourism.attraction',
        'tourism.sights',
        'entertainment.museum',
        'leisure.park',
        'catering.restaurant',
      ]);
    }

    return categories.toList();
  }
}