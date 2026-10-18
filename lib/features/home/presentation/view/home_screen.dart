import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:heraj/core/service/location_service/location_provider.dart';
import 'package:heraj/features/home/presentation/managers/fetch_home_data_provider.dart';
import 'components/new_products_widget.dart';
import 'widgets/categories_grid_widget.dart';
import 'widgets/complete_profile_banner.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/home_sliders.dart';
import 'components/real_estate_section.dart';
import 'widgets/stories_ads_section.dart';
import 'components/top_stores_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchHomeDataProvider);
          ref.invalidate(fetchLocationDetailsProvider);
        },
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: CustomScrollView(
            slivers: const [
              SliverToBoxAdapter(child: HomeHeaderWidget(isHome: true,)),
              SliverToBoxAdapter(child: CompleteProfileBanner()),
              SliverToBoxAdapter(child: StoriesAdsSection()),
              SliverToBoxAdapter(child: HomeSliders()),
              SliverToBoxAdapter(child: CategoriesGridWidget()),
              SliverToBoxAdapter(child: RealEstateSection()),
              SliverGap(10),
              SliverToBoxAdapter(child: HotDealsProductsSection()),
              SliverGap(10),
              SliverToBoxAdapter(child: AdminProductsSection()),
              SliverGap(10),
              SliverToBoxAdapter(child: NewProductsWidget()),
              SliverGap(10),
              SliverToBoxAdapter(child: TopStoresSection()),
              SliverGap(100),
            ],
          ),
        ),
      ),
    );
  }
}
