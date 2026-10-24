part of '../../public_profile_screen.dart';

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.page});

  final SellerReviews page;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reviews'.tr, style: AppFont.font16W700Black),
        const Gap(12),
        if (page.items.isEmpty)
          Text('No reviews'.tr, style: AppFont.font14W600Grey2)
        else
          for (final review in page.items) ...[
            _ReviewCard(review: review),
            const Gap(8),
          ],
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final SellerReview review;

  @override
  Widget build(BuildContext context) {
    final age = adAgeLabel(review.createdAt);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.primary2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: review.avatarUrl.isEmpty
                      ? ColoredBox(
                          color: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: AppColor.grey2,
                          ),
                        )
                      : ImageOrSvg(
                          review.avatarUrl,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              if (review.reviewerName.trim().isNotEmpty) ...[
                const Gap(8),
                Expanded(
                  child: Text(
                    review.reviewerName.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.font14W600Black,
                  ),
                ),
              ],
            ],
          ),
          const Gap(8),
          Semantics(
            label: '${review.rating}',
            child: Row(
              children: [
                for (var star = 1; star <= 5; star++)
                  Icon(
                    star <= review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 16,
                    color: const Color(0xffE39B00),
                  ),
              ],
            ),
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const Gap(8),
            Text(
              review.comment.trim(),
              style: AppFont.font14W600Black.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          if (age.isNotEmpty) ...[
            const Gap(8),
            Text(age, style: AppFont.font12w500Grey2),
          ],
        ],
      ),
    );
  }
}

class _ReviewsRetry extends StatelessWidget {
  const _ReviewsRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton(
        onPressed: onRetry,
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
        child: Text(
          'Try again'.tr,
          style: AppFont.font14W600Primary,
        ),
      ),
    );
  }
}
