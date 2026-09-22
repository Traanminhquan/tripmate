import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/presentation/widgets/empty_state.dart';

void main() {
  testWidgets(
    'shows title and message',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.luggage_outlined,
              title: 'No trips yet',
              message:
                  'Create your first trip.',
            ),
          ),
        ),
      );

      expect(
        find.text('No trips yet'),
        findsOneWidget,
      );

      expect(
        find.text(
          'Create your first trip.',
        ),
        findsOneWidget,
      );

      expect(
        find.byIcon(
          Icons.luggage_outlined,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'calls button callback',
    (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon:
                  Icons.luggage_outlined,
              title: 'No trips yet',
              message:
                  'Create your first trip.',
              buttonLabel:
                  'Create Trip',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(
        find.text('Create Trip'),
      );

      await tester.pump();

      expect(
        pressed,
        true,
      );
    },
  );
}