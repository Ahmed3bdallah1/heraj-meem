import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../gen/assets.gen.dart';
import '../../../config/app_font.dart';
import '../../../core/enum/language.dart';
import '../../../core/service/local_data_manager.dart';
import '../../../core/service/localization_service/localization_service.dart';
import '../../../helper/responsive.dart';
import '../../../ui/shared_widgets/custom_filled_button.dart';
import '../../auth/presentation/view/login_page.dart';

final isUserProvider = StateProvider<bool>((ref) => true);

class GetStartedScreen extends ConsumerWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    responsiveInit(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.67,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  Assets.base.getStarted1.path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: AppColor.backGround);
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(70),
                        Colors.black.withAlpha(140),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Image.asset(Assets.base.logoWhite.path,height: 100,)
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -200,
            left: -100,
            right: -100,
            child: CircleAvatar(
              radius: 340,
              backgroundColor: AppColor.white,
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!'.tr,
                    style: AppFont.font24w600Black.copyWith(
                      color: AppColor.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    'Choose your language'.tr,
                    style: AppFont.font14W500Black.copyWith(
                      color: AppColor.grey2,
                    ),
                  ),
                  const Gap(50),
                  CustomFilledButton(
                    text: 'English'.tr,
                    textSize: 16,
                    color: AppColor.primary,
                    fontColor: Colors.white,
                    onPressed: () => _continueWithLanguage(ref, Language.english),
                  ),
                  const Gap(16),
                  CustomFilledButton(
                    text: 'العربية'.tr,
                    textSize: 16,
                    color: AppColor.primary,
                    fontColor: Colors.white,
                    onPressed: () => _continueWithLanguage(ref, Language.arabic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _continueWithLanguage(WidgetRef ref, Language language) async {
  await localeService.changeLocale(language);
  await dataManager.setSecondTime();
  ref.read(isUserProvider.notifier).state = true;
  Get.offAll(() => LoginPage());
}
