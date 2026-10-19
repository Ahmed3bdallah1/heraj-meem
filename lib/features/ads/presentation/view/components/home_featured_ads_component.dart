import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/presentation/view/ad_details_screen.dart';
import 'package:heraj_meem/features/home/data/models/baho_feed.dart';
import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/home/presentation/view/widgets/home_entrance.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeFeaturedAdsComponent extends StatelessWidget {
  const HomeFeaturedAdsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeEntrance(
      index: 1,
      child: _FeaturedAdsSection(),
    );
  }
}

class _FeaturedAdsSection extends ConsumerStatefulWidget {
  const _FeaturedAdsSection();

  @override
  ConsumerState<_FeaturedAdsSection> createState() =>
      _FeaturedAdsSectionState();
}

class _FeaturedAdsSectionState extends ConsumerState<_FeaturedAdsSection> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    if (!_controller.hasClients) return;
    final target = (_controller.offset + delta)
        .clamp(0.0, _controller.position.maxScrollExtent);
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final featured = ref.watch(bahoFeaturedAdsProvider);
    return featured.when(
      loading: () => _HomeSkeleton(
        child: _FeaturedAdsBody(
          items: _placeholderFeaturedAds,
          controller: _controller,
          onScroll: _scrollBy,
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(error.toString(), style: AppFont.font12W600Primary),
      ),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return _FeaturedAdsBody(
          items: items,
          controller: _controller,
          onScroll: _scrollBy,
          animate: true,
        );
      },
    );
  }
}

class _ScrollButton extends StatelessWidget {
  const _ScrollButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 18, color: AppColor.grey2),
        ),
      ),
    );
  }
}

class _FeaturedAdCard extends StatelessWidget {
  const _FeaturedAdCard({required this.ad});

  final BahoAd ad;

  @override
  Widget build(BuildContext context) {
    return _PressScale(
      onTap: () => Get.to(() => AdDetailsScreen(productId: ad.id)),
      child: SizedBox(
        width: 156,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                height: 148,
                width: 156,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ad.imageUrl == null || ad.imageUrl!.isEmpty
                        ? const ColoredBox(
                            color: Color(0xffF3F3F3),
                            child: Icon(Icons.image_outlined),
                          )
                        : Image.network(
                            ad.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const ColoredBox(
                              color: Color(0xffF3F3F3),
                              child: Icon(Icons.image_outlined),
                            ),
                          ),
                    PositionedDirectional(
                      top: 8,
                      start: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFF4D6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Featured'.tr,
                          style: AppFont.font10w400Black.copyWith(
                            color: const Color(0xffE39B00),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(8),
            Text(
              ad.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFont.font12W600Primary.copyWith(
                color: AppColor.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            Text(
              ad.hasListedPrice
                  ? '${'SAR'.tr} ${ad.formattedPrice}'
                  : 'Contact the publisher'.tr,
              style: AppFont.font14W600Primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  const _PressScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  final ValueNotifier<double> _scale = ValueNotifier(1);

  @override
  void dispose() {
    _scale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scale.value = 0.98,
      onTapCancel: () => _scale.value = 1,
      onTapUp: (_) => _scale.value = 1,
      onTap: widget.onTap,
      child: ValueListenableBuilder<double>(
        valueListenable: _scale,
        builder: (context, scale, child) {
          return AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _FeaturedAdsBody extends StatelessWidget {
  const _FeaturedAdsBody({
    required this.items,
    required this.controller,
    required this.onScroll,
    this.animate = false,
  });

  final List<BahoAd> items;
  final ScrollController controller;
  final ValueChanged<double> onScroll;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffEEEEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xffF5B400),
                  size: 20,
                ),
                const Gap(4),
                Text('Featured Ads'.tr, style: AppFont.font16W700Black),
                const Spacer(),
                Text(
                  '${items.length} ${'Ad'.tr}',
                  style: AppFont.font14W500Grey2,
                ),
              ],
            ),
          ),
          const Gap(12),
          SizedBox(
            height: 236,
            child: Stack(
              children: [
                ListView.separated(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  physics: animate
                      ? null
                      : const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Gap(12),
                  itemBuilder: (context, index) {
                    final card = _FeaturedAdCard(ad: items[index]);
                    if (!animate) return card;
                    return HomeEntrance(index: index, slide: 12, child: card);
                  },
                ),
                PositionedDirectional(
                  top: 60,
                  start: 0,
                  child: _ScrollButton(
                    icon: Icons.chevron_right,
                    onTap: () => onScroll(-180),
                  ),
                ),
                PositionedDirectional(
                  top: 60,
                  end: 0,
                  child: _ScrollButton(
                    icon: Icons.chevron_left,
                    onTap: () => onScroll(180),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

const _placeholderFeaturedAds = [
  BahoAd(
    id: 'f1',
    title: 'Featured ad',
    price: '1200',
    currency: 'SAR',
    cityName: 'Riyadh',
    categoryName: 'Category',
    isFeatured: true,
  ),
  BahoAd(
    id: 'f2',
    title: 'Featured ad',
    price: '1200',
    currency: 'SAR',
    cityName: 'Riyadh',
    categoryName: 'Category',
    isFeatured: true,
  ),
  BahoAd(
    id: 'f3',
    title: 'Featured ad',
    price: '1200',
    currency: 'SAR',
    cityName: 'Riyadh',
    categoryName: 'Category',
    isFeatured: true,
  ),
];
