import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../../config/app_color.dart';

class AnimatedBackground extends StatelessWidget {
  final Animation<double> animation;

  const AnimatedBackground({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _AnimatedBackgroundPainter(animation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _AnimatedBackgroundPainter extends CustomPainter {
  final double animationValue;

  _AnimatedBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 3; i++) {
      final radius = 100.0 + (i * 50.0);
      final x = size.width * (0.2 + (i * 0.15)) +
          math.sin(animationValue * 2 * math.pi + i) * 30;
      final y = size.height * (0.1 + (i * 0.2)) +
          math.cos(animationValue * 2 * math.pi + i) * 30;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = AppColor.primary.withAlpha((8 - (i * 1)).round()),
      );
    }

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 80
      ..color = AppColor.primary.withAlpha(60)
      ..imageFilter = ImageFilter.blur(sigmaX: 10, sigmaY: 10);

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveHeight = 30.0;
      final waveLength = size.width / 2;
      final y = size.height * (0.3 + i * 0.2) +
          math.sin(animationValue * 2 * math.pi + i) * 20;

      path.moveTo(0, y);
      // Smoother wave path with smaller increments
      for (double x = 0; x < size.width; x += 2) {
        path.lineTo(
          x,
          y +
              math.sin((x / waveLength + animationValue) * 2 * math.pi) *
                  waveHeight,
        );
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(_AnimatedBackgroundPainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}
