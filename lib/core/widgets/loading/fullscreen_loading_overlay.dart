import 'package:flutter/material.dart';

import 'loading_dots.dart';

class FullScreenLoadingOverlay extends StatelessWidget {
  final bool visible;

  const FullScreenLoadingOverlay({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black45,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                  image: AssetImage('assets/images/ict_ipb_logo.png'),
                  width: 88,
                  height: 88,
                ),
                SizedBox(height: 16),
                LoadingDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
