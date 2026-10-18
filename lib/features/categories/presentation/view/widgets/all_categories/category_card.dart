import 'package:flutter/material.dart';
import '../../../../data/models/main_category_model.dart';
import '../../categories_layout.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryIconItem(category: category);
  }
}

