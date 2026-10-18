import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// class DisintegrationEffect extends StatelessWidget {
//   final Widget child;
//   final double time;
//   final double strength;
//   final double edgeBias;
//   final Offset windDirection;
//   final ui.FragmentProgram program;
//
//   const DisintegrationEffect({
//     super.key,
//     required this.child,
//     required this.program,
//     required this.time,
//     this.strength = 1.0,
//     this.edgeBias = 1.0,
//     this.windDirection = const Offset(1, -0.3),
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (_, constraints) {
//         final shader = program.fragmentShader();
//
//         shader.setFloat(0, time.clamp(0, 1));
//         shader.setFloat(1, constraints.maxWidth);
//         shader.setFloat(2, constraints.maxHeight);
//         shader.setFloat(3, strength);
//         shader.setFloat(4, edgeBias);
//
//         final dir = windDirection.distance == 0
//             ? const Offset(1, -0.3)
//             : windDirection / windDirection.distance;
//
//         shader.setFloat(5, dir.dx);
//         shader.setFloat(6, dir.dy);
//
//         return ShaderMask(
//           blendMode: BlendMode.srcOver,
//           shaderCallback: (_) => shader,
//           child: child,
//         );
//       },
//     );
//   }
// }

class DisintegrationEffect extends StatefulWidget {
  final Widget child;
  final double strength;
  final double edgeBias;
  final Offset windDirection;
  final ui.FragmentProgram program;

  const DisintegrationEffect({
    super.key,
    required this.child,
    required this.program,
    this.strength = 1.0,
    this.edgeBias = 1.0,
    this.windDirection = const Offset(1, -0.3),
  });

  @override
  State<DisintegrationEffect> createState() => _DisintegrationEffectState();

  /// Static run function
  static void run({
    required BuildContext context,
    required GlobalKey key,
    required VoidCallback onComplete,
    double strength = 1.0,
    double edgeBias = 1.0,
    Offset windDirection = const Offset(1, -0.3),
    required ui.FragmentProgram program,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject == null) return;

    final overlay = Overlay.of(context);

    final widget = key.currentWidget as Widget;

    // Declare 'entry' first so the closure can reference it
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _DisintegrationEffectOverlay(
          program: program,
          strength: strength,
          edgeBias: edgeBias,
          windDirection: windDirection,
          duration: duration,
          onComplete: () {
            entry.remove();
            onComplete();
          },
          child: widget,
        );
      },
    );

    overlay.insert(entry);
  }
}

class _DisintegrationEffectState extends State<DisintegrationEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return LayoutBuilder(
          builder: (_, constraints) {
            final shader = widget.program.fragmentShader();
            shader.setFloat(0, _controller.value.clamp(0, 1));
            shader.setFloat(1, constraints.maxWidth);
            shader.setFloat(2, constraints.maxHeight);
            shader.setFloat(3, widget.strength);
            shader.setFloat(4, widget.edgeBias);

            final dir = widget.windDirection.distance == 0
                ? const Offset(1, -0.3)
                : widget.windDirection / widget.windDirection.distance;

            shader.setFloat(5, dir.dx);
            shader.setFloat(6, dir.dy);

            return ShaderMask(
              blendMode: BlendMode.srcOver,
              shaderCallback: (_) => shader,
              child: widget.child,
            );
          },
        );
      },
    );
  }
}

/// Overlay helper to animate the effect on top of the existing widget
class _DisintegrationEffectOverlay extends StatefulWidget {
  final Widget child;
  final ui.FragmentProgram program;
  final double strength;
  final double edgeBias;
  final Offset windDirection;
  final Duration duration;
  final VoidCallback onComplete;

  const _DisintegrationEffectOverlay({
    required this.child,
    required this.program,
    required this.strength,
    required this.edgeBias,
    required this.windDirection,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<_DisintegrationEffectOverlay> createState() =>
      _DisintegrationEffectOverlayState();
}

class _DisintegrationEffectOverlayState
    extends State<_DisintegrationEffectOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return LayoutBuilder(
          builder: (_, constraints) {
            final shader = widget.program.fragmentShader();
            shader.setFloat(0, _controller.value.clamp(0, 1));
            shader.setFloat(1, constraints.maxWidth);
            shader.setFloat(2, constraints.maxHeight);
            shader.setFloat(3, widget.strength);
            shader.setFloat(4, widget.edgeBias);

            final dir = widget.windDirection.distance == 0
                ? const Offset(1, -0.3)
                : widget.windDirection / widget.windDirection.distance;

            shader.setFloat(5, dir.dx);
            shader.setFloat(6, dir.dy);

            return Center(
              child: ShaderMask(
                blendMode: BlendMode.srcOver,
                shaderCallback: (_) => shader,
                child: widget.child,
              ),
            );
          },
        );
      },
    );
  }
}



