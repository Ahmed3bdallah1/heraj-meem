import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/ui/shared_widgets/price_widget.dart';
import 'package:heraj_meem/core/service/localization_service/localization_service.dart';
import 'package:heraj_meem/features/products/data/models/product_details_model.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_badge_widget.dart';
import 'package:heraj_meem/main.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductDetailsModel product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            langCode == "en"
                ? product.name
                : langCode == "ar"
                    ? product.titleAr ?? ""
                    : product.titleTr ?? "",
            style: AppFont.font20W700Black,
          ),
          const Gap(12),
          Row(
            children: [
              PriceWidget(
                price: product.price.toStringAsFixed(2),
                style: AppFont.font24w600Black.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textColor: AppColor.primary,
                currencySize: 24,
              ),
              const SizedBox(width: 12),
              if (product.compareAtPrice > product.price)
                PriceWidget(
                  price: product.compareAtPrice.toStringAsFixed(2),
                  style: AppFont.font14W600Black,
                  textColor: AppColor.grey2,
                  decoration: TextDecoration.lineThrough,
                  currencySize: 16,
                ),
            ],
          ),
          const Gap(4),
          const Gap(8),
          Row(
            children: [
              ...List.generate(5, (index) {
                final rating = product.rating.average;
                if (index < rating.floor()) {
                  return Icon(
                    Icons.star,
                    color: AppColor.orange,
                    size: 16,
                  );
                } else if (index < rating.ceil() && rating % 1 != 0) {
                  return Icon(
                    Icons.star_half,
                    color: AppColor.orange,
                    size: 16,
                  );
                } else {
                  return Icon(
                    Icons.star_border,
                    color: AppColor.grey2,
                    size: 16,
                  );
                }
              }),
              const Gap(8),
              Text(
                '${product.rating.average.toStringAsFixed(1)} (${product.rating.count})',
                style: AppFont.font14W500Black.copyWith(
                  color: AppColor.grey2,
                ),
              ),
            ],
          ),
          // const Gap(8),
          // Row(
          //   children: [
          //     Icon(
          //       Icons.shopping_bag_outlined,
          //       size: 16,
          //       color: AppColor.grey2,
          //     ),
          //     const Gap(4),
          //     Text(
          //       "${"Purchased".tr} 121 ${"times".tr}",
          //       style: AppFont.font14W500Black.copyWith(
          //         color: AppColor.grey2,
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
