import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class AppAnimations {
  static const Duration pageDuration = Duration(milliseconds: 520);
  static const Duration contentDuration = Duration(milliseconds: 650);

  static PageRouteBuilder<T> pageRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: pageDuration,
      reverseTransitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (_, animation, _) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: Colors.transparent,
          child: child,
        );
      },
    );
  }
}

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
