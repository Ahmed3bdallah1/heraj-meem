import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/data/models/product_details_model.dart';
import 'package:heraj_meem/features/ads/presentation/managers/public_profile_provider.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj_meem/ui/shared_widgets/loading_widget.dart';

class PublisherSection extends ConsumerWidget {
  const PublisherSection({super.key, required this.product});

  final ProductDetailsModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerId = product.sellerId?.id ?? '';
    if (sellerId.isEmpty) return const SizedBox.shrink();

    final profile = ref.watch(publicProfileProvider(sellerId));
    return profile.customWhen(
      ref: ref,
      refreshable: publicProfileProvider(sellerId).future,
      loading: () => const _PublisherCard(child: LoadingWidget()),
      error: (_, __) => _PublisherCard(
        name: product.sellerId?.profile?.name ?? '',
        avatarUrl: product.sellerId?.profile?.avatar ?? '',
        cityName: [
          product.location?.district,
          product.location?.city,
        ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' · '),
        score: product.rating.average,
      ),
      data: (publisher) => _PublisherCard(
        name: publisher.displayName,
        avatarUrl: publisher.avatarUrl,
        cityName: publisher.cityName,
        score: publisher.score,
        bio: publisher.bio,
        phone: publisher.phone,
        memberNumber: publisher.memberNumber,
      ),
    );
  }
}

class _PublisherCard extends StatelessWidget {
  const _PublisherCard({
    this.child,
    this.name = '',
    this.avatarUrl = '',
    this.cityName = '',
    this.bio = '',
    this.phone = '',
    this.score = 0,
    this.memberNumber = 0,
  });

  final Widget? child;
  final String name;
  final String avatarUrl;
  final String cityName;
  final String bio;
  final String phone;
  final double score;
  final int memberNumber;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE6E6E6)),
        ),
        child: child ??
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Avatar(url: avatarUrl),
                const Gap(12),
                Expanded(child: _Details(
                  name: name,
                  cityName: cityName,
                  bio: bio,
                  phone: phone,
                  score: score,
                  memberNumber: memberNumber,
                )),
              ],
            ),
      ),
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
        width: 52,
        height: 52,
        child: url.isEmpty
            ? const ColoredBox(
                color: Color(0xffF3F3F3),
                child: Icon(Icons.person, color: Color(0xff9A9A9A)),
              )
            : ImageOrSvg(url, width: 52, height: 52, fit: BoxFit.cover),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.name,
    required this.cityName,
    required this.bio,
    required this.phone,
    required this.score,
    required this.memberNumber,
  });

  final String name;
  final String cityName;
  final String bio;
  final String phone;
  final double score;
  final int memberNumber;

  @override
  Widget build(BuildContext context) {
    final shownName = name.trim().isEmpty ? 'Publisher'.tr : name.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Publisher'.tr,
          style: AppFont.font12W600Primary.copyWith(
            color: AppColor.grey2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(2),
        Text(
          shownName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFont.font16W700Black,
        ),
        if (memberNumber > 0) ...[
          const Gap(2),
          Text(
            '${'Member number'.tr} $memberNumber',
            style: AppFont.font12W600Primary.copyWith(
              color: AppColor.grey2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
        if (score > 0 || cityName.trim().isNotEmpty) ...[
          const Gap(4),
          Row(
            children: [
              if (score > 0) ...[
                const Icon(Icons.star_rounded, size: 16, color: Color(0xffE39B00)),
                const Gap(2),
                Text(
                  score.toStringAsFixed(1),
                  style: AppFont.font12W600Primary.copyWith(color: AppColor.black),
                ),
              ],
              if (score > 0 && cityName.trim().isNotEmpty)
                Text(
                  '  ·  ',
                  style: AppFont.font12W600Primary.copyWith(color: AppColor.grey2),
                ),
              if (cityName.trim().isNotEmpty)
                Expanded(
                  child: Text(
                    cityName.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.font12W600Primary.copyWith(
                      color: AppColor.grey2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (bio.trim().isNotEmpty) ...[
          const Gap(6),
          Text(
            bio.trim(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppFont.font12W600Primary.copyWith(
              color: AppColor.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
        if (phone.trim().isNotEmpty) ...[
          const Gap(4),
          Text(
            phone.trim(),
            style: AppFont.font12W600Primary.copyWith(color: AppColor.primary),
          ),
        ],
      ],
    );
  }
}
