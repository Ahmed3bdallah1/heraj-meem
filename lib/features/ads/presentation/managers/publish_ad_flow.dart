import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/domain/use_case/create_ad_use_case.dart';
import 'package:heraj_meem/features/ads/presentation/managers/products_managers.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/publish_ad_confirmation_sheet.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/ui.dart';

Future<void> confirmPublishAd(
  BuildContext context,
  WidgetRef ref,
  String adId,
) {
  return PublishAdConfirmationSheet.show(
    context,
    onConfirm: () async {
      final result = await getIt<PublishAdUseCase>().call(adId);
      return result.fold((failure) {
        UIHelper.showGlobalSnackBar(
          text: failure.message,
          color: AppColor.danger,
        );
        return false;
      }, (_) {
        ref.invalidate(fetchMyAdsProvider);
        ref.invalidate(fetchMyAdProvider(adId));
        ref.invalidate(fetchProductByIdProvider(adId));
        UIHelper.showGlobalSnackBar(
          text: 'Ad published successfully'.tr,
          color: AppColor.green,
        );
        return true;
      });
    },
  );
}
