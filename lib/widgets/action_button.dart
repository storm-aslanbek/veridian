import 'package:flutter/material.dart';
import 'package:veridian/theme.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isFullWidth;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = icon != null
        ? Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label),
      ],
    )
        : Text(label);

    if (isPrimary) {
      return isFullWidth
          ? SizedBox(
        width: double.infinity,
        child: ElevatedButton(onPressed: onPressed, child: child),
      )
          : ElevatedButton(onPressed: onPressed, child: child);
    } else {
      return isFullWidth
          ? SizedBox(
        width: double.infinity,
        child: OutlinedButton(onPressed: onPressed, child: child),
      )
          : OutlinedButton(onPressed: onPressed, child: child);
    }
  }
}
