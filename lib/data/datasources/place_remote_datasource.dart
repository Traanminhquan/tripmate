import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/place_model.dart';

class PlaceRemoteDataSource {
  final Dio dio;

  PlaceRemoteDataSource({
    required this.dio,
  });

  Future<List<PlaceModel>> searchCities(
    String query,
  ) async {
    if (ApiConstants
        .geoapifyApiKey.isEmpty) {
      throw Exception(
        'Geoapify API key is missing. '
      );
    }

    if (query.trim().isEmpty) {
      return [];
    }

    final response = await dio.get(
      '/v1/geocode/search',
      queryParameters: {
        'text': query.trim(),
        'type': 'city',
        'format': 'geojson',
        'limit': 10,
        'lang': 'en',
        'apiKey':
            ApiConstants.geoapifyApiKey,
      },
    );

    final data =
        response.data
            as Map<String, dynamic>;

    final features =
        data['features'] as List? ?? [];

    return features
        .map(
          (item) =>
              PlaceModel.fromGeoapify(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList();
  }

  Future<List<PlaceModel>> getPlaces({
    required double latitude,
    required double longitude,
    required String category,
  }) async {
    final response = await dio.get(
      '/v2/places',
      queryParameters: {
        'categories': category,

        'filter':
            'circle:$longitude,$latitude,5000',

        'bias':
            'proximity:$longitude,$latitude',

        'limit': 20,

        'apiKey':
            ApiConstants.geoapifyApiKey,
      },
    );

    final data =
        response.data
            as Map<String, dynamic>;

    final features =
        data['features'] as List? ?? [];

    return features
        .map(
          (item) =>
              PlaceModel.fromGeoapify(
            Map<String, dynamic>.from(
              item as Map,
            ),
          ),
        )
        .toList();
  }
}