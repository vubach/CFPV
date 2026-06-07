import 'package:flutter/material.dart';
import '../../theme/colors.dart';

/// Three animated pulsing dots for loading states.
class LoadingDots extends StatefulWidget {
  final Color? color;

  const LoadingDots({super.key, this.color});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? CFPVColors.greenAccent;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            final phase = (_controller.value + index / 3) % 1.0;
            final opacity = 0.3 + 0.7 * (1.0 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: child,
            );
          },
          child: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
