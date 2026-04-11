import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

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
