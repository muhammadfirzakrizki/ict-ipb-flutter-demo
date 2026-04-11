import 'package:flutter/material.dart';

import 'app_animations.dart';

class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset begin;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = AppAnimations.contentDuration,
    this.begin = const Offset(0, 16),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(begin.dx * (1 - value), begin.dy * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
