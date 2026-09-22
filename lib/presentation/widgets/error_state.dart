import 'package:flutter/material.dart';

class ErrorState
    extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final message = error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),

            if (onRetry != null) ...[
              const SizedBox(
                height: 18,
              ),

              OutlinedButton.icon(
                onPressed:
                    onRetry,
                icon: const Icon(
                  Icons.refresh,
                ),
                label:
                    const Text(
                  'Retry',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}