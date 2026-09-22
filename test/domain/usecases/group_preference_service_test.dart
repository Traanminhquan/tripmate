import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/domain/usecases/group_preference_service.dart';

void main() {
  late GroupPreferenceService service;

  setUp(() {
    service = GroupPreferenceService();
  });

  test(
    'should rank group preferences by vote count',
    () {
      final result = service.calculate(
        memberPreferences: const [
          [
            'Food',
            'Culture',
            'Photography',
          ],
          [
            'Food',
            'Nature',
          ],
          [
            'Food',
            'Culture',
            'Nature',
          ],
        ],
      );

      expect(
        result.scores['Food'],
        3,
      );

      expect(
        result.scores['Culture'],
        2,
      );

      expect(
        result.scores['Nature'],
        2,
      );

      expect(
        result.scores['Photography'],
        1,
      );

      expect(
        result.rankedPreferences.first,
        'Food',
      );
    },
  );

  test(
    'duplicate preference from one member counts once',
    () {
      final result = service.calculate(
        memberPreferences: const [
          [
            'Food',
            'Food',
            'Food',
          ],
          [
            'Food',
          ],
        ],
      );

      expect(
        result.scores['Food'],
        2,
      );
    },
  );
}