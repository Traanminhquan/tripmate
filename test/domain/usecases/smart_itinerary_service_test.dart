import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/domain/entities/place.dart';
import 'package:tripmate/domain/entities/trip_activity.dart';
import 'package:tripmate/domain/usecases/smart_itinerary_service.dart';

void main() {
  late SmartItineraryService service;

  setUp(() {
    service =
        SmartItineraryService();
  });

  Place place(
    String id,
    double lat,
    double lng,
  ) {
    return Place(
      id: id,
      name: id,
      latitude: lat,
      longitude: lng,
    );
  }

  test(
    'should exclude places already in itinerary',
    () {
      final result =
          service.generate(
        places: [
          place(
            'A',
            21.0,
            105.0,
          ),
          place(
            'B',
            21.1,
            105.1,
          ),
          place(
            'C',
            21.2,
            105.2,
          ),
        ],
        startDate:
            DateTime(2026, 9, 22),
        endDate:
            DateTime(2026, 9, 22),
        existingPlaceIds: const [
          'A',
        ],
        existingActivities:
            const [],
        placesPerDay: 3,
      );

      final ids = result
          .map(
            (item) =>
                item.place.id,
          )
          .toList();

      expect(
        ids.contains('A'),
        false,
      );

      expect(
        ids.contains('B'),
        true,
      );
    },
  );

  test(
    'should respect max activities per day',
    () {
      final existing = [
        TripActivity(
          id: 'a1',
          tripId: 'trip1',
          title: 'Existing',
          location: 'Hanoi',
          date:
              DateTime(2026, 9, 22),
          startTime: '09:00',
          order: 0,
        ),
        TripActivity(
          id: 'a2',
          tripId: 'trip1',
          title: 'Existing 2',
          location: 'Hanoi',
          date:
              DateTime(2026, 9, 22),
          startTime: '13:00',
          order: 1,
        ),
      ];

      final result =
          service.generate(
        places: [
          place(
            'A',
            21.0,
            105.0,
          ),
          place(
            'B',
            21.1,
            105.1,
          ),
          place(
            'C',
            21.2,
            105.2,
          ),
        ],
        startDate:
            DateTime(2026, 9, 22),
        endDate:
            DateTime(2026, 9, 22),
        existingPlaceIds:
            const [],
        existingActivities:
            existing,
        placesPerDay: 3,
      );

      expect(
        result.length,
        1,
      );
    },
  );

  test(
    'should avoid time conflict within 2 hours',
    () {
      final existing = [
        TripActivity(
          id: 'a1',
          tripId: 'trip1',
          title: 'Existing',
          location: 'Hanoi',
          date:
              DateTime(2026, 9, 22),
          startTime: '10:00',
          order: 0,
        ),
      ];

      final result =
          service.generate(
        places: [
          place(
            'A',
            21.0,
            105.0,
          ),
          place(
            'B',
            21.1,
            105.1,
          ),
        ],
        startDate:
            DateTime(2026, 9, 22),
        endDate:
            DateTime(2026, 9, 22),
        existingPlaceIds:
            const [],
        existingActivities:
            existing,
        placesPerDay: 3,
      );

      final times = result
          .map(
            (item) =>
                item.startTime,
          )
          .toList();

      expect(
        times.contains('09:00'),
        false,
      );
    },
  );
}