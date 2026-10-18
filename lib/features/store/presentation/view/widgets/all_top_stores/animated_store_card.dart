import 'package:flutter/material.dart';
import '../../../../data/models/store_model.dart';
import 'store_card.dart';

class AnimatedStoreCard extends StatelessWidget {
  final StoreModel store;
  final int index;

  const AnimatedStoreCard({
    super.key,
    required this.store,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(store.id),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100).clamp(0, 500)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final clampedValue = value.clamp(0.0, 1.0);
        return Transform.scale(
          scale: clampedValue,
          child: Opacity(
            opacity: clampedValue,
            child: RepaintBoundary(
              child: StoreCard(store: store),
            ),
          ),
        );
      },
    );
  }
}

