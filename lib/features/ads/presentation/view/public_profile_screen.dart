import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/data/models/product_details_model.dart';
import 'package:heraj_meem/features/ads/data/models/public_profile_model.dart';
import 'package:heraj_meem/features/ads/data/models/seller_reviews.dart';
import 'package:heraj_meem/features/ads/presentation/managers/public_profile_actions_mixin.dart';
import 'package:heraj_meem/features/ads/presentation/managers/public_profile_provider.dart';
import 'package:heraj_meem/features/ads/presentation/managers/seller_reviews_provider.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/home_ads_morph.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_outlined_button.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

part 'widgets/public_profile/seller_reviews_section.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  const PublicProfileScreen({
    super.key,
    required this.userId,
    this.product,
  });

  final String userId;
  final ProductDetailsModel? product;

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen>
    with PublicProfileActionsMixin {
  @override
  void dispose() {
    disposeProfileActions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(publicProfileProvider(widget.userId));
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: profile.customWhen(
        ref: ref,
        refreshable: publicProfileProvider(widget.userId).future,
        loading: () => Skeletonizer(
          enabled: true,
          ignorePointers: true,
          containersColor: AppColor.primary.withAlpha(22),
          effect: ShimmerEffect(
            baseColor: Color.lerp(AppColor.primary, Colors.white, 0.72)!,
            highlightColor: Color.lerp(AppColor.primary, Colors.white, 0.9)!,
            duration: const Duration(milliseconds: 1200),
          ),
          child: _ProfileBody(
            top: top,
            bottom: bottom,
            profile: _placeholderProfile,
            rating: _placeholderProfile.score,
            reviewCount: 3,
            showActions: true,
            chatting: chatting,
            onCall: () {},
            onChat: () {},
            reviews: const _ReviewList(
              page: SellerReviews(
                items: [
                  SellerReview(
                    id: '1',
                    reviewerName: 'Sara',
                    avatarUrl: '',
                    rating: 5,
                    comment: 'Great seller',
                    createdAt: '',
                  ),
                ],
                average: 4.8,
                total: 3,
              ),
            ),
          ),
        ),
        data: (publisher) {
          final mine = isOwnProfile(publisher.id);
          final reviews = ref.watch(sellerReviewsProvider(widget.userId));
          final summary = reviews.valueOrNull;
          final rating = summary != null && summary.average > 0
              ? summary.average
              : publisher.score;
          return _ProfileBody(
            top: top,
            bottom: bottom,
            profile: publisher,
            rating: rating,
            reviewCount: summary?.total ?? 0,
            showActions: !mine,
            chatting: chatting,
            onCall: () => callPublisher(publisher),
            onChat: () => chatPublisher(publisher),
            reviews: reviews.customWhen(
              ref: ref,
              refreshable: sellerReviewsProvider(widget.userId).future,
              loading: () => const Skeletonizer(
                enabled: true,
                child: _ReviewList(
                  page: SellerReviews(
                    items: [
                      SellerReview(
                        id: 'loading',
                        reviewerName: 'Sara',
                        avatarUrl: '',
                        rating: 5,
                        comment: 'Great seller',
                        createdAt: '',
                      ),
                    ],
                    average: 5,
                    total: 1,
                  ),
                ),
              ),
              error: (_, __) => _ReviewsRetry(
                onRetry: () {
                  ref
                      .refresh(sellerReviewsProvider(widget.userId).future)
                      .then((_) {});
                },
              ),
              data: (page) => _ReviewList(page: page),
            ),
          );
        },
      ),
    );
  }
}

const _placeholderProfile = PublicProfileModel(
  id: 'publisher',
  displayName: 'Heba Yasser',
  avatarUrl: '',
  bio: 'Publisher on Baho',
  phone: '',
  cityName: 'Riyadh',
  regionName: 'Riyadh',
  score: 4.8,
  memberNumber: 120,
);

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.top,
    required this.bottom,
    required this.profile,
    required this.rating,
    required this.reviewCount,
    required this.showActions,
    required this.reviews,
    required this.chatting,
    required this.onCall,
    required this.onChat,
  });

  final double top;
  final double bottom;
  final PublicProfileModel profile;
  final double rating;
  final int reviewCount;
  final bool showActions;
  final Widget reviews;
  final ValueNotifier<bool> chatting;
  final VoidCallback onCall;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName.trim().isEmpty
        ? 'Publisher'.tr
        : profile.displayName.trim();
    final place = [
      profile.cityName,
      profile.regionName,
    ].where((part) => part.trim().isNotEmpty).join(' · ');
    final scoreLabel = rating > 0 ? rating.toStringAsFixed(1) : '—';
    final memberLabel =
        profile.memberNumber > 0 ? '${profile.memberNumber}' : '—';
    final reviewsLabel = reviewCount > 0 ? '$reviewCount' : '—';

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, top + 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back'.tr,
                  onPressed: Get.back,
                  icon: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_back_rounded,
                    color: AppColor.black,
                  ),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: AppColor.primary2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.font16W700Black,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, bottom + 24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Avatar(url: profile.avatarUrl),
                    const Gap(24),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _Stat(
                              value: scoreLabel,
                              label: 'Rating'.tr,
                            ),
                          ),
                          Expanded(
                            child: _Stat(
                              value: reviewsLabel,
                              label: 'Reviews'.tr,
                            ),
                          ),
                          Expanded(
                            child: _Stat(
                              value: memberLabel,
                              label: 'Member number'.tr,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                Text(
                  name,
                  style: AppFont.font18W700Black,
                ),
                if (place.isNotEmpty) ...[
                  const Gap(8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColor.grey2,
                      ),
                      const Gap(4),
                      Expanded(
                        child: Text(
                          place,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFont.font14W600Grey2,
                        ),
                      ),
                    ],
                  ),
                ],
                if (profile.bio.trim().isNotEmpty) ...[
                  const Gap(8),
                  Text(
                    profile.bio.trim(),
                    style: AppFont.font14W600Black.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                if (showActions) ...[
                  const Gap(24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomOutlinedButton(
                          text: 'Call'.tr,
                          color: AppColor.primary,
                          textColor: AppColor.primary,
                          height: 48,
                          radius: 12,
                          widget: Icon(
                            Icons.phone_outlined,
                            color: AppColor.primary,
                            size: 20,
                          ),
                          onPressed: onCall,
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: chatting,
                          builder: (context, busy, _) {
                            return CustomFilledButton(
                              text: 'Chat'.tr,
                              color: AppColor.primary,
                              height: 48,
                              radius: 12,
                              isLoading: busy,
                              widget: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: onChat,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const Gap(24),
                reviews,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 96,
        height: 96,
        child: url.isEmpty
            ? ColoredBox(
                color: AppColor.primary2,
                child: Icon(Icons.person, size: 40, color: AppColor.grey2),
              )
            : ImageOrSvg(url, width: 96, height: 96, fit: BoxFit.cover),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppFont.font18W700Black,
        ),
        const Gap(4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppFont.font12w500Grey2,
        ),
      ],
    );
  }
}
