import 'package:flutter/material.dart';

class AuthBackgroundDecor extends StatelessWidget {
  const AuthBackgroundDecor({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          left: -60,
          child: CircleAvatar(
            radius: 120,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.07),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -40,
          child: CircleAvatar(
            radius: 150,
            backgroundColor: colorScheme.secondary.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }
}
