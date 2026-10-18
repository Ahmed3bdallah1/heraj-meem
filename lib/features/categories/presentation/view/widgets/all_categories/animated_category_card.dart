import 'package:flutter/material.dart';
import '../../../../data/models/main_category_model.dart';
import 'category_card.dart';

class AnimatedCategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int index;

  const AnimatedCategoryCard({
    super.key,
    required this.category,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(category.id),
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
              child: CategoryCard(category: category),
            ),
          ),
        );
      },
    );
  }
}

