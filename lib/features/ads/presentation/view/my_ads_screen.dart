import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/ads/presentation/managers/products_managers.dart';
import 'package:heraj_meem/features/ads/presentation/managers/publish_ad_flow.dart';
import 'package:heraj_meem/features/ads/presentation/view/ad_details_screen.dart';
import 'package:heraj_meem/features/ads/presentation/view/add_ad_screen.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/home_ads_morph.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj_meem/ui/shared_widgets/shimmer_effect.dart';

part 'widgets/my_ads/my_ad_tile.dart';

class MyAdsScreen extends ConsumerStatefulWidget {
  const MyAdsScreen({super.key});

  @override
  ConsumerState<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends ConsumerState<MyAdsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ValueNotifier<String> _query = ValueNotifier('');
  final ValueNotifier<String> _status = ValueNotifier('all');

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _query.dispose();
    _status.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads = ref.watch(fetchMyAdsProvider);
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColor.primary2,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColor.primary2,
        surfaceTintColor: Colors.transparent,
        title: Text('My Ads'.tr, style: AppFont.font18W700Black),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchMyAdsProvider);
          await ref.read(fetchMyAdsProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _SearchField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (value) => _query.value = value.trim().toLowerCase(),
            )),
            SliverToBoxAdapter(child: _StatusFilters(selected: _status)),
            ads.customWhen(
              ref: ref,
              refreshable: fetchMyAdsProvider.future,
              skipLoadingOnRefresh: true,
              loading: () => const SliverToBoxAdapter(child: _MyAdsSkeleton()),
              data: (items) => ValueListenableBuilder<String>(
                valueListenable: _query,
                builder: (context, query, _) {
                  return ValueListenableBuilder<String>(
                    valueListenable: _status,
                    builder: (context, status, _) {
                      final shown = items
                          .where((ad) => _matchesQuery(ad, query))
                          .where((ad) => _matchesStatus(ad, status))
                          .toList();
                      if (shown.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyAds(
                            canCreate: items.isEmpty,
                            bottom: bottom,
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, bottom + 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 220),
                                    child: Text(
                                      '%s ads'.trArgs(['${shown.length}']),
                                      key: ValueKey(shown.length),
                                      style: AppFont.font12w500Grey2,
                                    ),
                                  ),
                                );
                              }
                              final ad = shown[index - 1];
                              return _MyAdTile(
                                key: ValueKey(ad.id),
                                index: index - 1,
                                product: ad,
                                onPublish: () =>
                                    confirmPublishAd(context, ref, ad.id),
                              );
                            },
                            childCount: shown.length + 1,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => focusNode.unfocus(),
        onChanged: onChanged,
        style: AppFont.font14W500Black,
        decoration: InputDecoration(
          hintText: 'Search'.tr,
          hintStyle: AppFont.font14W500Black.copyWith(color: AppColor.grey2),
          prefixIcon: Icon(Icons.search, color: AppColor.grey2),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _StatusFilters extends StatelessWidget {
  const _StatusFilters({required this.selected});

  final ValueNotifier<String> selected;

  static const _filters = [
    ('all', 'All'),
    ('active', 'Active'),
    ('draft', 'Draft'),
    ('pending', 'Pending Review'),
    ('expired', 'Expired'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ValueListenableBuilder<String>(
        valueListenable: selected,
        builder: (context, current, _) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final filter in _filters) ...[
                  _FilterChip(
                    label: filter.$2.tr,
                    selected: current == filter.$1,
                    onTap: () => selected.value = filter.$1,
                  ),
                  const Gap(8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? AppColor.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: AppFont.font14W600Black.copyWith(
              color: selected ? Colors.white : AppColor.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyAds extends StatelessWidget {
  const _EmptyAds({required this.canCreate, required this.bottom});

  final bool canCreate;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 24, 32, bottom + 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: AppColor.grey2),
          const Gap(16),
          Text(
            'No ads found'.tr,
            textAlign: TextAlign.center,
            style: AppFont.font16W600Black,
          ),
          if (canCreate) ...[
            const Gap(16),
            LayoutBuilder(
              builder: (context, constraints) {
                return CustomFilledButton(
                  width: constraints.maxWidth,
                  height: 48,
                  radius: 16,
                  text: 'Create your first ad'.tr,
                  onPressed: () => Get.to(() => const AddAdScreen()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _MyAdsSkeleton extends StatelessWidget {
  const _MyAdsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            ShimmerEffect(
              enable: true,
              child: Container(
                height: 136,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const Gap(12),
          ],
        ],
      ),
    );
  }
}

bool _matchesQuery(ProductModel ad, String query) {
  if (query.isEmpty) return true;
  return ad.name.toLowerCase().contains(query) ||
      (ad.titleAr ?? '').toLowerCase().contains(query);
}

bool _matchesStatus(ProductModel ad, String filter) {
  final status = ad.status.toUpperCase();
  switch (filter) {
    case 'active':
      return status == 'ACTIVE' || status == 'APPROVED';
    case 'draft':
      return status == 'DRAFT';
    case 'pending':
      return status == 'PENDING' || status == 'PENDING_REVIEW';
    case 'expired':
      return status == 'EXPIRED';
    default:
      return true;
  }
}
