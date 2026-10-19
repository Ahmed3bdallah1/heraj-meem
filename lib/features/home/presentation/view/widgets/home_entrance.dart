import 'package:flutter/material.dart';

class HomeEntrance extends StatelessWidget {
  const HomeEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.slide = 14,
    this.beginScale = 1,
  });

  final Widget child;
  final int index;
  final double slide;
  final double beginScale;

  @override
  Widget build(BuildContext context) {
    final delay = index.clamp(0, 8) * 50;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, slide * (1 - value)),
            child: Transform.scale(
              scale: beginScale + ((1 - beginScale) * value),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
