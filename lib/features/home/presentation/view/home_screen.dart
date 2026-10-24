import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:heraj_meem/features/ads/presentation/view/components/home_ads_grid_component.dart';
import 'package:heraj_meem/features/ads/presentation/view/components/home_featured_ads_component.dart';
import 'package:heraj_meem/features/ads/presentation/view/components/home_photos_filter_component.dart';
import 'package:heraj_meem/features/categories/presentation/view/components/home_categories_component.dart';
import 'package:heraj_meem/core/service/auth_service.dart';
import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/home/presentation/managers/home_logic_mixin.dart';

import 'components/home_header_component.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with HomeLogicMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) seedSavedPlace();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProvider, (previous, next) {
      if (ref.read(bahoPlaceProvider) != null) return;
      seedSavedPlace();
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: onAdsScroll,
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: HomeHeaderComponent()),
                SliverToBoxAdapter(child: HomeFeaturedAdsComponent()),
                SliverToBoxAdapter(child: HomeCategoriesComponent()),
                SliverToBoxAdapter(child: HomePhotosFilterComponent()),
                SliverToBoxAdapter(child: HomeAdsGridComponent()),
                SliverGap(50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
