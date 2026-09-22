import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../data/datasources/place_remote_datasource.dart';
import '../../data/repositories/place_repository_impl.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/place_repository.dart';

final geoapifyDioProvider =
    Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl:
          ApiConstants.geoapifyBaseUrl,
      connectTimeout:
          const Duration(
        seconds: 10,
      ),
      receiveTimeout:
          const Duration(
        seconds: 10,
      ),
    ),
  );
});

final placeRemoteDataSourceProvider =
    Provider<PlaceRemoteDataSource>(
  (ref) {
    return PlaceRemoteDataSource(
      dio: ref.read(
        geoapifyDioProvider,
      ),
    );
  },
);

final placeRepositoryProvider =
    Provider<PlaceRepository>(
  (ref) {
    return PlaceRepositoryImpl(
      remoteDataSource: ref.read(
        placeRemoteDataSourceProvider,
      ),
    );
  },
);

final citySearchProvider =
    FutureProvider.family<
        List<Place>,
        String>(
  (ref, query) async {
    if (query.trim().length < 2) {
      return [];
    }

    return ref
        .read(placeRepositoryProvider)
        .searchCities(query);
  },
);