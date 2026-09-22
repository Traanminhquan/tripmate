import 'package:flutter/material.dart';

class AppSnackbar {
  static void success(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  static void error(
    BuildContext context,
    Object? error,
  ) {
    final message = error
            ?.toString()
            .replaceFirst(
              'Exception: ',
              '',
            ) ??
        'Something went wrong.';

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  static void info(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}