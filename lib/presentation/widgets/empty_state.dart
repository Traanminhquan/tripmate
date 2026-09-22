import 'package:flutter/material.dart';

class EmptyState
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color:
                  Colors.grey.shade400,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              title,
              style:
                  Theme.of(context)
                      .textTheme
                      .titleLarge,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),

            if (buttonLabel != null &&
                onPressed != null) ...[
              const SizedBox(
                height: 20,
              ),

              ElevatedButton(
                onPressed:
                    onPressed,
                child: Text(
                  buttonLabel!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}