import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../data/models/product_model.dart';
import 'widgets/sell_all_products/animated_background.dart';
import 'widgets/sell_all_products/animated_product_card.dart';
import 'widgets/sell_all_products/empty_products_state.dart';
import 'widgets/sell_all_products/products_app_bar.dart';

class SectionProductsScreen extends StatefulWidget {
  final String title;
  final List<ProductModel> products;
  final Color? primaryColor;

  const SectionProductsScreen({
    super.key,
    required this.title,
    required this.products,
    this.primaryColor,
  });

  @override
  State<SectionProductsScreen> createState() => _SectionProductsScreenState();
}

class _SectionProductsScreenState extends State<SectionProductsScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            animation: _backgroundAnimationController,
            primaryColor: widget.primaryColor,
          ),
          CustomScrollView(
            slivers: [
              ProductsAppBar(
                title: widget.title,
                primaryColor: widget.primaryColor,
              ),
              if (widget.products.isEmpty)
                const EmptyProductsState()
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemBuilder: (context, index) {
                      final product = widget.products[index];
                      return AnimatedProductCard(
                        product: product,
                        index: index,
                      );
                    },
                    childCount: widget.products.length,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

