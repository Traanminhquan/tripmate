import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/presentation/widgets/error_state.dart';

void main() {
  testWidgets(
    'shows cleaned error message',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              error: Exception(
                'Failed to load data',
              ),
            ),
          ),
        ),
      );

      expect(
        find.text(
          'Failed to load data',
        ),
        findsOneWidget,
      );

      expect(
        find.text(
          'Exception: Failed to load data',
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'calls retry callback',
    (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              error: Exception(
                'Failed',
              ),
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(
        find.text('Retry'),
        findsOneWidget,
      );

      await tester.tap(
        find.text('Retry'),
      );

      await tester.pump();

      expect(
        retried,
        true,
      );
    },
  );
}