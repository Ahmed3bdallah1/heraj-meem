import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/favorites/presentation/view/widgets/favorite_widgets.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../config/app_font.dart';
import '../managers/favorites.dart';

class FavoritesListScreen extends ConsumerStatefulWidget {
  const FavoritesListScreen({super.key});

  @override
  ConsumerState<FavoritesListScreen> createState() =>
      _FavoritesListScreenState();
}

class _FavoritesListScreenState extends ConsumerState<FavoritesListScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Animated AppBar
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.white.withAlpha(230),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColor.black,
                ),
                onPressed: () => Get.back(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 16, right: 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Favorites".tr,
                    style: AppFont.font18W700Black,
                  ),
                  const Gap(8),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 2),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.9 + (value * 0.1),
                        child: Transform.rotate(
                          angle: (1 - value) * 0.3,
                          child: Icon(
                            Icons.favorite_rounded,
                            color: AppColor.danger,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              centerTitle: false,
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(favoritesProvider);
              },
              child: Consumer(
                builder: (context, ref, _) {
                  final provider = ref.watch(favoritesProvider);
                  return provider.customWhen(
                    ref: ref,
                    refreshable: favoritesProvider.future,
                    skipLoadingOnRefresh: true,
                    skipLoadingOnReload: true,
                    loading: () => const _FavoritesSkeleton(),
                    data: (data) {
                      if (data.isEmpty) {
                        return _EmptyFavoritesState();
                      }
                      return Column(
                        children: [
                          const Gap(16),
                          ...data.asMap().entries.map((entry) {
                            return AnimatedFavoriteCard(
                              key: ValueKey(entry.value.id),
                              index: entry.key,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                child: FavoriteWidget(
                                  favoritesModel: entry.value,
                                ),
                              ),
                            );
                          }),
                          Gap(MediaQuery.of(context).padding.bottom + 16),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesSkeleton extends StatelessWidget {
  const _FavoritesSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Color.lerp(AppColor.primary, Colors.white, 0.72)!;
    final highlight = Color.lerp(AppColor.primary, Colors.white, 0.9)!;
    return Skeletonizer(
      enabled: true,
      ignorePointers: true,
      containersColor: AppColor.primary.withAlpha(22),
      effect: ShimmerEffect(
        baseColor: base,
        highlightColor: highlight,
        duration: const Duration(milliseconds: 1200),
      ),
      child: Column(
        children: [
          const Gap(16),
          for (var index = 0; index < 4; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FavoriteWidget(
                favoritesModel: _placeholderFavorite(index),
              ),
            ),
          Gap(MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

ProductModel _placeholderFavorite(int index) {
  return ProductModel(
    id: 'skeleton-$index',
    name: 'Favorite ad title',
    sku: '',
    isFeatured: false,
    isFavorite: true,
    productType: 'customer',
    images: const [],
    badges: const [],
    status: 'ACTIVE',
    stock: 1,
    variants: const [],
    variantCombinations: const [],
    isFeaturedDeal: false,
    views: 0,
    specifications: const [],
    priceHistory: const [],
    createdAt: '',
    updatedAt: '',
    v: 0,
    price: 1200,
    category: Category(id: index, name: 'Category'),
    averageRating: '4.5',
  );
}

class AnimatedFavoriteCard extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedFavoriteCard({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<AnimatedFavoriteCard> createState() => _AnimatedFavoriteCardState();
}

class _AnimatedFavoriteCardState extends State<AnimatedFavoriteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Start animation after a small delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) {
        _controller.forward();
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
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyFavoritesState extends StatefulWidget {
  const _EmptyFavoritesState();

  @override
  State<_EmptyFavoritesState> createState() => _EmptyFavoritesStateState();
}

class _EmptyFavoritesStateState extends State<_EmptyFavoritesState>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _pulseController;
  late Animation<double> _heartAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _heartAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120 + (_pulseAnimation.value * 40),
                    height: 120 + (_pulseAnimation.value * 40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.danger.withOpacity(
                        0.1 * (1 - _pulseAnimation.value),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 100 + (_pulseAnimation.value * 30),
                    height: 100 + (_pulseAnimation.value * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.danger.withOpacity(
                        0.15 * (1 - _pulseAnimation.value),
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _heartAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.danger.withAlpha(50),
                            AppColor.danger.withAlpha(25),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        size: 64,
                        color: AppColor.danger,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const Gap(32),
          // Title with fade animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              "No Products have been favorited yet.".tr,
              style: AppFont.font20W700Black,
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(12),
          // Message with fade animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "go back and add some products to your favorites.".tr,
                style: AppFont.font14W500Black.copyWith(
                  color: AppColor.grey2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Gap(32),
          // Button without animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primary,
                    AppColor.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withAlpha(100),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const Gap(12),
                        Text(
                          "Go to Products".tr,
                          style: AppFont.font16W600Black.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
