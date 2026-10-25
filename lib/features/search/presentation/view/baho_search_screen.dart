import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/home_ads_morph.dart';
import 'package:heraj_meem/features/search/presentation/managers/baho_search_actions_mixin.dart';
import 'package:heraj_meem/features/search/presentation/managers/baho_search_provider.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_text_field.dart';
import 'package:heraj_meem/ui/shared_widgets/loading_widget.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BahoSearchScreen extends ConsumerStatefulWidget {
  const BahoSearchScreen({super.key, required this.query});

  final String query;

  @override
  ConsumerState<BahoSearchScreen> createState() => _BahoSearchScreenState();
}

class _BahoSearchScreenState extends ConsumerState<BahoSearchScreen>
    with BahoSearchActionsMixin {
  @override
  void initState() {
    super.initState();
    initSearch(widget.query);
  }

  @override
  void dispose() {
    disposeSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(bahoSearchProvider(widget.query));
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(8, top + 8, 16, 8),
            child: ReactiveForm(
              formGroup: form,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back'.tr,
                    onPressed: Get.back,
                    icon: Icon(Icons.arrow_back_rounded, color: AppColor.black),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(48, 48),
                      backgroundColor: const Color(0xffF3F4F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: CustomTextField(
                      formControlName: 'query',
                      hintText: 'Search in Baho...'.tr,
                      focusNode: searchFocus,
                      textInputAction: TextInputAction.search,
                      radius: 16,
                      onChanged: (control) =>
                          onQueryChanged('${control.value ?? ''}'),
                      iconDataPrefix: Icon(
                        CupertinoIcons.search,
                        color: AppColor.grey2,
                        size: 20,
                      ),
                      onEditDone: submitSearch,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: results.customWhen(
              ref: ref,
              refreshable: bahoSearchProvider(widget.query).future,
              skipLoadingOnRefresh: false,
              loading: () => const _SearchResultsSkeleton(),
              data: (items) {
                if (items.isEmpty) return const _SearchEmpty();
                final showFooter =
                    !ref.read(bahoSearchProvider(widget.query).notifier).isLastPage();
                return ListView.separated(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    MediaQuery.of(context).padding.bottom + 24,
                  ),
                  itemCount: items.length + (showFooter ? 1 : 0),
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LoadingWidget(size: 24),
                      );
                    }
                    return HomeAdListCard(product: items[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchEmpty extends StatelessWidget {
  const _SearchEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.search, size: 48, color: AppColor.grey2),
            const Gap(16),
            Text(
              'No products found'.tr,
              style: AppFont.font16W700Black,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'Try another search'.tr,
              style: AppFont.font14W500Black.copyWith(color: AppColor.grey2),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsSkeleton extends StatelessWidget {
  const _SearchResultsSkeleton();

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
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: 3,
        separatorBuilder: (_, __) => const Gap(12),
        itemBuilder: (_, index) => HomeAdListCard(
          product: _placeholderAd(index),
        ),
      ),
    );
  }
}

ProductModel _placeholderAd(int index) {
  return ProductModel(
    id: 'search-skeleton-$index',
    name: 'Ad title',
    sku: '',
    isFeatured: false,
    isFavorite: false,
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
    createdAt: '2026-10-18T10:00:00.000Z',
    updatedAt: '',
    v: 0,
    price: 1200,
    sellerName: 'Seller',
    titleAr: 'عنوان الإعلان',
  );
}
