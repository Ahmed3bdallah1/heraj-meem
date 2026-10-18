import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/products/data/models/product_details_model.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';

import '../../../../../core/service/localization_service/localization_service.dart';
import '../../../../../main.dart';

class ProductDescriptionSection extends StatelessWidget {
  final ProductDetailsModel product;

  const ProductDescriptionSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(4),
          HtmlWidget(
            langCode == "en"
                ? product.description
                : langCode == "ar"
                ? product.descriptionAr ?? ""
                : product.descriptionTr ?? "",
            textStyle: AppFont.font15W400Black.copyWith(
              color: AppColor.grey2,
              height: 1.6,
            ),
          ),
          const Gap(32),
        ],
      ),
    );
  }
}

