import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/presentation/managers/add_ad_actions_mixin.dart';
import 'package:heraj_meem/features/home/data/models/baho_feed.dart';
import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/notifications/presentation/view/notifications_screen.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj_meem/ui/shared_widgets/loading_widget.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_outlined_button.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:reactive_forms/reactive_forms.dart';

part 'widgets/add_ad/add_ad_category_step.dart';
part 'widgets/add_ad/add_ad_category_tile.dart';
part 'widgets/add_ad/add_ad_check_mark.dart';
part 'widgets/add_ad/add_ad_city_step.dart';
part 'widgets/add_ad/add_ad_continue_button.dart';
part 'widgets/add_ad/add_ad_details_step.dart';
part 'widgets/add_ad/add_ad_pending_step.dart';
part 'widgets/add_ad/add_ad_photo_box.dart';
part 'widgets/add_ad/add_ad_photo_tile.dart';
part 'widgets/add_ad/add_ad_progress_bar.dart';
part 'widgets/add_ad/add_ad_progress_segment.dart';
part 'widgets/add_ad/add_ad_step_title.dart';
part 'widgets/add_ad/add_ad_step_title_item.dart';

class AddAdScreen extends ConsumerStatefulWidget {
  const AddAdScreen({super.key});

  @override
  ConsumerState<AddAdScreen> createState() => _AddAdScreenState();
}

class _AddAdScreenState extends ConsumerState<AddAdScreen>
    with AddAdActionsMixin {
  @override
  void dispose() {
    disposeAddAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(addAdStepIndexProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: handleBack,
        ),
        title: Text('Add Ad'.tr, style: AppFont.font16W700Black),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () => Get.to(() => const NotificationsScreen()),
          ),
        ],
      ),
      body: ReactiveForm(
        formGroup: form,
        child: Column(
          children: [
            const _AddAdProgressBar(),
            const _AddAdStepTitles(),
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AddAdCityStep(selectedCity: selectedCity),
                  _AddAdCategoryStep(
                    selectedCategory: selectedCategory,
                    trail: categoryTrail,
                  ),
                  _AddAdDetailsStep(
                    photos: photos,
                    showPhone: showPhone,
                    titleFocus: titleFocus,
                    priceFocus: priceFocus,
                    descriptionFocus: descriptionFocus,
                    onPickImages: pickImages,
                    onRemoveImage: removeImage,
                  ),
                  _AddAdPendingStep(
                    createdAdId: createdAdId,
                    onViewAd: viewCreatedAd,
                    onGoHome: goHome,
                  ),
                ],
              ),
            ),
            if (step < 3)
              _AddAdContinueButton(
                step: step,
                submitting: submitting,
                onPressed: handleContinue,
              ),
          ],
        ),
      ),
    );
  }
}
