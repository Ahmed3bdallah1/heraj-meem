import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/local_data_manager.dart';
import 'package:heraj_meem/core/service/localization_service/localization_service.dart';
import 'package:heraj_meem/features/products/data/models/product_details_model.dart';
import 'package:heraj_meem/main.dart';

class ProductSpecificationsSection extends StatelessWidget {
  final ProductDetailsModel product;

  const ProductSpecificationsSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final langCode = dataManager.getLanguage?.locale.languageCode??"ar";
    print(langCode);

    if (product.specifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Specifications".tr,
            style: AppFont.font18W700Black,
          ),
          const Gap(16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.grey1),
            ),
            child: Column(
              children: [
                ...product.specifications.mapWithIndex((entry, index) {
                  final isLast = index == product.specifications.length - 1;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                langCode == 'ar'
                                    ? entry.keyAr ?? ""
                                    : langCode == 'tr'
                                        ? entry.keyTr ?? ""
                                        : entry.key,
                                style: AppFont.font14W600Black,
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              flex: 3,
                              child: Text(
                                langCode == 'ar'
                                    ? entry.valueAr ?? ""
                                    : langCode == 'tr'
                                    ? entry.valueTr ?? ""
                                    : entry.value,
                                style: AppFont.font15W400Black.copyWith(
                                  color: AppColor.grey2,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColor.grey1,
                          indent: 16,
                          endIndent: 16,
                        ),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          const Gap(32),
        ],
      ),
    );
  }
}
