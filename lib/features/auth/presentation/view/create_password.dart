import 'package:heraj/helper/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/features/root/view/root_view.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/app_font.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../ui/shared_widgets/custom_app_bar.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../../../ui/shared_widgets/custom_text_field.dart';
import '../../../../../ui/shared_widgets/toggle_show_password_icon.dart';
import 'login_page.dart';

class CreatePassword extends StatefulWidget {
  const CreatePassword({super.key});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  final formGroup = FormGroup({
    'password': FormControl<String>(validators: [Validators.required]),
    'confirm': FormControl<String>(validators: [Validators.required]),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "",
        customTitleWidget: Image.asset(
          Assets.base.logo.path,
        ),
      ),
      body: ReactiveForm(
        formGroup: formGroup,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(16.h),
                Text("Create password".tr,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Gap(8.h),
                Text(
                    "Verification completed successfully, complete the following information data"
                        .tr,
                    style: AppFont.font13W600Grey2),
                Gap(16.h),
                LinearProgressIndicator(
                  minHeight: 10.h,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  value: 1,
                  color: AppColor.primary,
                  backgroundColor: Colors.white,
                ),
                Gap(48.h),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: ("password".tr), style: AppFont.labelTextField),
                  TextSpan(
                      text: "*",
                      style: AppFont.labelTextField
                          .copyWith(color: Colors.red, fontSize: 18)),
                ])),
                Gap(16.h),
                Consumer(builder: (context, ref, _) {
                  return CustomTextField(
                    formControlName: "password",
                    hintText: "**********",
                    iconButton: ToggleShowPasswordButton(
                      onTap: () {
                        ref
                                .read(securePasswordProvider("password").notifier)
                                .state =
                            !ref.read(securePasswordProvider("password"));
                      },
                      showPass: ref.watch(securePasswordProvider("password")),
                    ),
                    obscure: ref.watch(securePasswordProvider("password")),
                  );
                }),
                Gap(16.h),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: ("confirm password".tr),
                      style: AppFont.labelTextField),
                  TextSpan(
                      text: "*",
                      style: AppFont.labelTextField
                          .copyWith(color: Colors.red, fontSize: 18)),
                ])),
                Gap(16.h),
                Consumer(builder: (context, ref, _) {
                  return CustomTextField(
                    formControlName: "confirm",
                    hintText: "**********",
                    iconButton: ToggleShowPasswordButton(
                      onTap: () {
                        ref
                                .read(securePasswordProvider("confirm").notifier)
                                .state =
                            !ref.read(securePasswordProvider("confirm"));
                      },
                      showPass: ref.watch(securePasswordProvider("confirm")),
                    ),
                    obscure: ref.watch(securePasswordProvider("confirm")),
                  );
                }),
                Gap(24.h),
                ReactiveFormConsumer(builder: (context, form, _) {
                  bool isValid = form.valid &&
                      form.controls["password"]!.value ==
                          form.controls["confirm"]!.value;
                  return CustomFilledButton(
                    text: "next".tr,
                    onPressed: () => Get.to(const RootView()),
                    isValid: isValid,
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
