class GroupPreferenceResult {
  final Map<String, int> scores;
  final List<String> rankedPreferences;

  const GroupPreferenceResult({
    required this.scores,
    required this.rankedPreferences,
  });
}

class GroupPreferenceService {
  GroupPreferenceResult calculate({
    required List<List<String>> memberPreferences,
  }) {
    final scores = <String, int>{};

    for (final preferences in memberPreferences) {
      final uniquePreferences =
          preferences
              .map(
                (item) => item.trim(),
              )
              .where(
                (item) => item.isNotEmpty,
              )
              .toSet();

      for (final preference
          in uniquePreferences) {
        scores.update(
          preference,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final ranked =
        scores.entries.toList()
          ..sort(
            (a, b) {
              final scoreCompare =
                  b.value.compareTo(
                a.value,
              );

              if (scoreCompare != 0) {
                return scoreCompare;
              }

              return a.key.compareTo(
                b.key,
              );
            },
          );

    return GroupPreferenceResult(
      scores: scores,
      rankedPreferences:
          ranked
              .map(
                (entry) => entry.key,
              )
              .toList(),
    );
  }
}