import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/localization_service/localization_service.dart';
import 'package:heraj_meem/features/products/data/models/product_details_model.dart';
import 'package:heraj_meem/features/products/presentation/view/widgets/product_tile.dart';
import 'package:heraj_meem/main.dart';

class ProductInfoCardsSection extends StatelessWidget {
  final ProductDetailsModel product;

  const ProductInfoCardsSection({super.key, required this.product});

  String _getWarrantyText() {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (product.warranty == null || !product.warranty!.hasWarranty) {
      return '';
    }
    if (langCode == 'ar') {
      return product.warranty!.durationAr ?? product.warranty!.duration ?? '';
    } else if (langCode == 'tr') {
      return product.warranty!.durationTr ?? product.warranty!.duration ?? '';
    }
    return product.warranty!.duration ?? '';
  }

  String _getDeliveryText() {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (product.deliveryInfo == null) {
      return '';
    }
    final days = product.deliveryInfo!.estimatedDays;
    if (langCode == 'ar') {
      return 'التوصيل خلال $days أيام';
    } else if (langCode == 'tr') {
      return '$days gün içinde teslimat';
    }
    return 'Delivery within $days days';
  }

  String _getFreeShippingText() {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (langCode == 'ar') {
      return 'شحن مجاني';
    } else if (langCode == 'tr') {
      return 'Ücretsiz kargo';
    }
    return 'Free shipping';
  }

  String _getShippingFromText() {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (langCode == 'ar') {
      return 'الشحن من تركيا';
    } else if (langCode == 'tr') {
      return 'Türkiye\'den kargo';
    }
    return 'Shipping from Turkey';
  }

  String _getFasterDeliveryText() {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (langCode == 'ar') {
      return 'تسليم أسرع للعملاء المحليين';
    } else if (langCode == 'tr') {
      return 'Yerel müşteriler için daha hızlı teslimat';
    }
    return 'Faster delivery for local customers';
  }

  String _getWarrantyLabel() {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (langCode == 'ar') {
      return 'الضمان';
    } else if (langCode == 'tr') {
      return 'Garanti';
    }
    return 'Warranty';
  }

  String _getDeliveryInfoLabel() {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (langCode == 'ar') {
      return 'معلومات التوصيل';
    } else if (langCode == 'tr') {
      return 'Teslimat Bilgisi';
    }
    return 'Delivery Information';
  }

  String _getLiveText() {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (langCode == 'ar') {
      return 'مباشر';
    } else if (langCode == 'tr') {
      return 'Canlı';
    }
    return 'Live';
  }

  String _getViewersText(int count) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (langCode == 'ar') {
      return '$count يشاهدون';
    } else if (langCode == 'tr') {
      return '$count izliyor';
    }
    return '$count viewers';
  }

  String _getAvailableText(int stock) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (langCode == 'ar') {
      return 'متوفر ($stock متاح)';
    } else if (langCode == 'tr') {
      return 'Mevcut ($stock mevcut)';
    }
    return 'Available ($stock available)';
  }

  @override
  Widget build(BuildContext context) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    final isRTL = langCode == 'ar';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.views > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isRTL) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            _getLiveText(),
                            style: AppFont.font12W600Black.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      '${product.views}',
                      style: AppFont.font14W600Black,
                    ),
                    const Gap(4),
                    Text(
                      _getViewersText(product.views)
                          .replaceFirst(
                            product.views.toString(),
                            '',
                          )
                          .trim(),
                      style: AppFont.font14W600Black,
                    ),
                  ] else ...[
                    Text(
                      _getViewersText(product.views)
                          .replaceFirst(
                            product.views.toString(),
                            '',
                          )
                          .trim(),
                      style: AppFont.font14W600Black,
                    ),
                    const Gap(4),
                    Text(
                      '${product.views}',
                      style: AppFont.font14W600Black,
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            _getLiveText(),
                            style: AppFont.font12W600Black.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.deliveryInfo != null)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: AppColor.green,
                              size: 20,
                            ),
                            const Gap(6),
                            Expanded(
                              child: Text(
                                _getDeliveryInfoLabel(),
                                style: AppFont.font12W600Black,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        if (product.deliveryInfo!.estimatedDays > 0)
                          Text(
                            _getDeliveryText(),
                            style: AppFont.font12w400Black.copyWith(
                              color: AppColor.grey2,
                            ),
                          ),
                        if (product.deliveryInfo!.freeShipping) ...[
                          if (product.deliveryInfo!.estimatedDays > 0)
                            const Gap(4),
                          Text(
                            _getFreeShippingText(),
                            style: AppFont.font12w400Black.copyWith(
                              color: AppColor.grey2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              if (product.deliveryInfo != null && product.warranty != null)
                const Gap(12),
              if (product.warranty != null && product.warranty!.hasWarranty)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shield,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const Gap(6),
                            Expanded(
                              child: Text(
                                _getWarrantyLabel(),
                                style: AppFont.font12W600Black,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        if (_getWarrantyText().isNotEmpty)
                          Text(
                            _getWarrantyText(),
                            style: AppFont.font12w400Black.copyWith(
                              color: AppColor.grey2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          if (product.deliveryInfo != null && product.deliveryInfo!.isInTurkey)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primary2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColor.primary,
                      size: 20,
                    ),
                    const Gap(4),
                    Text(
                      'TR',
                      style: AppFont.font12W600Black,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getShippingFromText(),
                            style: AppFont.font12W600Black,
                          ),
                          const Gap(4),
                          Text(
                            _getFasterDeliveryText(),
                            style: AppFont.font12w400Black.copyWith(
                              color: AppColor.grey2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (product.stock > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment:
                    isRTL ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColor.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    _getAvailableText(product.stock),
                    style: AppFont.font12W600Black,
                  ),
                ],
              ),
            ),
          const Gap(16),
        ],
      ),
    );
  }
}
