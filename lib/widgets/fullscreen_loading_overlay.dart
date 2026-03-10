import 'package:flutter/material.dart';

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
                _LoadingDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: 3,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final frame = (_controller.value * 3).floor() % 3;
        final dots = List.generate(3, (index) => index <= frame ? '.' : ' ');
        return Text(dots.join(), style: textStyle);
      },
    );
  }
}
