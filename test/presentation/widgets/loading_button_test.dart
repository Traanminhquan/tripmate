import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripmate/presentation/widgets/loading_button.dart';

void main() {
  testWidgets(
    'shows label when not loading',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Save',
              isLoading: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(
        find.text('Save'),
        findsOneWidget,
      );

      expect(
        find.byType(
          CircularProgressIndicator,
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'shows loading indicator',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Save',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(
        find.byType(
          CircularProgressIndicator,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'calls onPressed',
    (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Save',
              isLoading: false,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(
        find.text('Save'),
      );

      await tester.pump();

      expect(
        pressed,
        true,
      );
    },
  );

  testWidgets(
    'cannot press while loading',
    (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: 'Save',
              isLoading: true,
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      final button = tester.widget<
          ElevatedButton>(
        find.byType(
          ElevatedButton,
        ),
      );

      expect(
        button.onPressed,
        isNull,
      );

      expect(
        pressed,
        false,
      );
    },
  );
}