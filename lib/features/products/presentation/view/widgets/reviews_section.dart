import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/products/data/models/review_model.dart';
import 'package:heraj/features/products/presentation/managers/products_managers.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import 'package:heraj/ui/shared_widgets/custom_image_circle.dart';
import 'package:heraj/features/products/domain/repo/product_repo.dart';
import 'package:heraj/main.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/features/products/presentation/view/widgets/add_review_bottom_sheet.dart';

class ReviewsSection extends ConsumerWidget {
  final String productId;
  final bool isReviewEnabled;

  const ReviewsSection(
      {super.key, required this.productId, required this.isReviewEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(fetchProductReviewsProvider(productId));

    return reviewsAsync.customWhen(
      refreshable: fetchProductReviewsProvider(productId).future,
      ref: ref,
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Product Reviews".tr,
              style: AppFont.font18W700Black,
            ),
            const Gap(16),
            ShimmerEffect(
                enable: true,
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                )),
          ],
        ),
      ),
      data: (ProductReviewsModel data) {
        print(data.reviews);
        if (data.reviews.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Product Reviews".tr,
                      style: AppFont.font18W700Black,
                    ),
                    if (isReviewEnabled &&
                        !data.reviews.any((review) =>
                            review.userId == dataManager.getUserId())) ...[
                      Spacer(),
                      TextButton(
                          onPressed: () async {
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) =>
                                  AddReviewBottomSheet(productId: productId),
                            );
                            ref.watch(fetchProductReviewsProvider(productId));
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: AppColor.primary,
                              ),
                              Text(
                                "Add Review".tr,
                                style: AppFont.font12W600Primary,
                              )
                            ],
                          ))
                    ]
                  ],
                ),
                const Gap(8),
                Text(
                  "There are no reviews for this product yet.".tr,
                  style: AppFont.font12w400Black.copyWith(
                    color: AppColor.grey2,
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Product Reviews".tr,
                    style: AppFont.font18W700Black,
                  ),
                  if (isReviewEnabled &&
                      !data.reviews.any((review) =>
                          review.userId == dataManager.getUserId())) ...[
                    Spacer(),
                    TextButton(
                        onPressed: () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) =>
                                AddReviewBottomSheet(productId: productId),
                          );
                          ref.watch(fetchProductReviewsProvider(productId));
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              color: AppColor.primary,
                            ),
                            Text(
                              "Add Review".tr,
                              style: AppFont.font12W600Primary,
                            )
                          ],
                        ))
                  ]
                ],
              ),
              const Gap(16),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 180,
                  minHeight: 100,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: data.reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) =>
                      _buildReviewCard(data.reviews[index], context),
                ),
              ),
              const Gap(32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(ProductReview review, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .8,
      constraints: BoxConstraints(
        maxHeight: review.images.isNotEmpty ? 200 : 150,
        minHeight: 100,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.grey1,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomImageCircle(image: review.userImage),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: AppFont.font16W600Black,
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating ? Icons.star : Icons.star_border,
                            color: AppColor.primary,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Consumer(builder: (context, ref, child) {
                final currentUserId = ref.read(userIdProvider);
                return Row(
                  children: [
                    Text("(${review.helpfulCount})"),
                    if (review.userId != currentUserId)
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          color: AppColor.primary,
                          size: 20,
                        ),
                        onPressed: () {
                          getIt<ProductRepo>().reviewHelpful(review.id);
                          ref.invalidate(
                              fetchProductReviewsProvider(productId));
                        },
                      ),
                  ],
                );
              })
            ],
          ),
          const Gap(12),
          if (review.comment.isNotEmpty) ...[
            Text(
              review.comment,
              style: AppFont.font15W400Black.copyWith(
                color: AppColor.grey2,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 2,
            ),
          ],
          if (review.images.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: ImageOrSvg(
                      review.images[index],
                      height: 60,
                      width: 60,
                      fit: BoxFit.fill,
                      magnifier: true,
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }
}
