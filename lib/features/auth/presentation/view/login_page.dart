import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/core/service/auth_service.dart';
import 'package:heraj_meem/core/service/google_sign_in_service.dart';
import 'package:heraj_meem/core/service/local_data_manager.dart';
import 'package:heraj_meem/features/root/view/root_view.dart';
import 'package:heraj_meem/gen/assets.gen.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/shared_widgets/container_button.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/app_font.dart';
import '../../../../../helper/responsive.dart';
import '../../../../../helper/phone_validation_mixin.dart';
import '../../../../../ui/shared_widgets/custom_reactive_form_consumer.dart';
import '../../../../../ui/shared_widgets/custom_text_field.dart';
import '../../../../../ui/ui.dart';
import '../../../onboarding/view/get_started_screen.dart' show isUserProvider;
import '../manager/auth_provuder.dart';
import '../view/widgets/otp_bottom_sheet.dart';

final securePasswordProvider =
    StateProvider.family.autoDispose<bool, dynamic>((ref, _) => true);
final isRememberProvider = StateProvider.autoDispose<bool>((ref) => false);

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with PhoneValidationMixin {
  late final FormGroup formGroup;
  final FocusNode phoneNode = FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (dataManager.getFingerprintEnabled() &&
          ref.read(userProvider)?.id != null) {
        _localAuth();
      }
    });

    formGroup = FormGroup({
      'country_code': FormControl<String>(
        value: '+90',
        validators: [Validators.required],
      ),
      'phone': FormControl<String>(
        validators: [
          Validators.required,
        ],
      ),
    });

    formGroup.control('phone').setValidators([
      Validators.required,
      Validators.minLength(getPhoneLengthForCountryCode(
          formGroup.control('country_code').value)!),
      Validators.maxLength(getPhoneLengthForCountryCode(
          formGroup.control('country_code').value)!),
    ]);

    formGroup.control('country_code').valueChanges.listen((_) {
      formGroup.control('phone').updateValueAndValidity();
    });

    super.initState();
  }

  Future<void> _localAuth() async {
    final local = getIt<LocalAuthentication>();
    if (await local.authenticate(localizedReason: "Authenticate To Login".tr)) {
      Get.offAll(() => const RootView());
    }
  }

  @override
  void dispose() {
    super.dispose();
    formGroup.dispose();
    phoneNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    responsiveInit(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height * 0.5,
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
                      child: Image.asset(
                    Assets.base.logoWhite.path,
                    width: width * .5,
                  )),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: -height * (ref.watch(isUserProvider) ? .21 : .18),
            left: -width * .25,
            right: -width * .25,
            child: CircleAvatar(
              radius: height * .5,
              backgroundColor: AppColor.white,
            ),
          ),
          Positioned(
            bottom: ref.watch(isUserProvider)
                ? height * .1
                : MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: ReactiveForm(
              formGroup: formGroup,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      'Please type your phone number'.tr,
                      style: AppFont.font14W500Black.copyWith(
                        color: AppColor.grey2,
                      ),
                    ),
                    const Gap(24),
                    Row(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReactiveValueListenableBuilder<String>(
                          formControlName: 'country_code',
                          builder: (context, countryCodeControl, child) {
                            final phoneCode =
                                (!(countryCodeControl.value?.contains("+") ??
                                            false)
                                        ? '+${countryCodeControl.value}'
                                        : countryCodeControl.value) ??
                                    '+90';
                            Country country =
                                getCountryFromPhoneCode(phoneCode);

                            return InkWell(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  onSelect: (Country selectedCountry) {
                                    formGroup
                                        .control('country_code')
                                        .updateValue(
                                          selectedCountry.phoneCode,
                                          emitEvent: true,
                                        );
                                  },
                                  countryListTheme: CountryListThemeData(
                                    flagSize: 24,
                                    backgroundColor: Colors.white,
                                    textStyle: AppFont.font14W500Black,
                                    inputDecoration: InputDecoration(
                                      labelText: 'Search'.tr,
                                      hintText: 'Start typing to search'.tr,
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppColor.primary2,
                                        ),
                                      ),
                                    ),
                                    searchTextStyle: AppFont.font14W500Black,
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 48,
                                decoration: BoxDecoration(
                                  // color: AppColor.primary2,
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                      color: AppColor.grey1, width: 2),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      country.flagEmoji,
                                      style: AppFont.font20W700Black,
                                    ),
                                    const Gap(6),
                                    Text(
                                      country.phoneCode,
                                      style: AppFont.font14W500Black,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: CustomTextField(
                            radius: 25,
                            formControlName: "phone",
                            hintText: "Enter Phone Number".tr,
                            inputType: TextInputType.phone,
                            inputFormatter: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            focusNode: phoneNode,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),
                    CustomReactiveFormValidationConsumer(
                      formGroup: formGroup,
                      builder: (context, _, child) {
                        return Consumer(builder: (context, ref, child) {
                          final isLoading = ref.watch(authNotifierProvider);
                          return CustomFilledButton(
                            isLoading: isLoading,
                            isValid: formGroup.valid,
                            text: "Log In".tr,
                            textSize: 16,
                            color: AppColor.primary,
                            fontColor: Colors.white,
                            onPressed: () async {
                              if (formGroup.valid) {
                                final countryCode =
                                    formGroup.value['country_code'] as String;
                                final phoneNumber =
                                    formGroup.value['phone'] as String;

                                try {
                                  final preLoginResponse = await ref
                                      .read(authNotifierProvider.notifier)
                                      .preLogin({
                                    'phone': phoneNumber,
                                    'countryCode': countryCode,
                                    'role': 'customer',
                                  });
                                  if (preLoginResponse != null &&
                                      preLoginResponse.success) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => OTPBottomSheet(
                                        phoneNumber: phoneNumber,
                                        countryCode: countryCode,
                                        isLoading: isLoading,
                                        onVerify: (otp) async {
                                          try {
                                            Navigator.pop(context);
                                            await ref
                                                .read(authNotifierProvider
                                                    .notifier)
                                                .login({
                                              'phone': phoneNumber,
                                              'countryCode': countryCode,
                                              'otp': otp,
                                              'role': ref.watch(isUserProvider)
                                                  ? 'customer'
                                                  : 'vendor',
                                            });
                                          } catch (e) {
                                            UIHelper.showAlert(
                                              e.toString(),
                                              type: DialogType.error,
                                            );
                                          }
                                        },
                                        onResend: () async {
                                          try {
                                            await ref
                                                .read(authNotifierProvider
                                                    .notifier)
                                                .preLogin({
                                              'phone': phoneNumber,
                                              'countryCode': countryCode,
                                              'role': ref.watch(isUserProvider)
                                                  ? 'customer'
                                                  : 'vendor',
                                            });
                                          } catch (e) {
                                            UIHelper.showAlert(
                                              e.toString(),
                                              type: DialogType.error,
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  UIHelper.showAlert(e.toString(),
                                      type: DialogType.error);
                                }
                              } else {
                                formGroup.markAllAsTouched();
                              }
                            },
                          );
                        });
                      },
                    ),
                    const Gap(24),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            "Or".tr,
                            style: AppFont.font14W600Grey2,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // ContainerButton(
                          //   radius: 25,
                          //   size: 60,
                          //   color: Colors.transparent,
                          //   widget: Padding(
                          //     padding: EdgeInsets.all(8.0),
                          //     child: Image.asset(
                          //       Assets.socialMedia.facebook.path,
                          //       width: 50,
                          //       height: 50,
                          //     ),
                          //   ),
                          //   onTap: () {},
                          // ),
                          if (Platform.isIOS)
                            ContainerButton(
                              radius: 25,
                              size: 60,
                              color: Colors.transparent,
                              widget: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Image.asset(
                                  Assets.socialMedia.apple.path,
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                              onTap: () {},
                            ),
                          ContainerButton(
                            radius: 25,
                            size: 60,
                            color: Colors.transparent,
                            widget: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Image.asset(
                                Assets.socialMedia.gmail.path,
                                width: 50,
                                height: 50,
                              ),
                            ),
                            onTap: () async {
                              try {
                                final googleSignInService =
                                    GoogleSignInService();
                                final result = await googleSignInService
                                    .signInAndGetIdToken();

                                if (!result.success) {
                                  print(result.idToken);
                                  print(result.success);
                                  print(result.error);
                                  UIHelper.showGlobalSnackBar(
                                    text: result.error ??
                                        'Google sign in cancelled'.tr,
                                    color: AppColor.danger,
                                  );
                                  return;
                                }

                                await ref
                                    .read(authNotifierProvider.notifier)
                                    .socialLogin(result.idToken ?? "");
                              } catch (e) {
                                UIHelper.showGlobalSnackBar(
                                  text:
                                      'Error signing in with Google: ${e.toString()}'
                                          .tr,
                                  color: AppColor.danger,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    if (dataManager.getFingerprintEnabled() &&
                        ref.watch(userProvider)?.id != null) ...[
                      const Gap(24),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Or Login with fingerprint".tr,
                              style: AppFont.font10w400Black,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Gap(24),
                      InkWell(
                        onTap: _localAuth,
                        child: Center(
                          child: SvgPicture.asset(
                            Assets.base.eye,
                            width: 48,
                            height: 48,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
