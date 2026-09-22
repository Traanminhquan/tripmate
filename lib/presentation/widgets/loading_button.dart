import 'package:flutter/material.dart';

class LoadingButton
    extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData? icon;

  const LoadingButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (icon != null) {
      return ElevatedButton.icon(
        onPressed:
            isLoading
                ? null
                : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(label),
      );
    }

    return ElevatedButton(
      onPressed:
          isLoading
              ? null
              : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}