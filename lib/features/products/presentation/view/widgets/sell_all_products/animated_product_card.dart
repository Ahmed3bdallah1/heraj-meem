import 'package:flutter/material.dart';
import '../../../../data/models/product_model.dart';
import '../product_tile.dart';

class AnimatedProductCard extends StatelessWidget {
  final ProductModel product;
  final int index;

  const AnimatedProductCard({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(product.id),
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
              child: ProductTile(product: product),
            ),
          ),
        );
      },
    );
  }
}

