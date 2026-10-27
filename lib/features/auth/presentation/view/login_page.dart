import 'package:awesome_dialog/awesome_dialog.dart';
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
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../config/app_font.dart';
import '../../../../../helper/responsive.dart';
import '../../../../../ui/shared_widgets/custom_reactive_form_consumer.dart';
import '../../../../../ui/shared_widgets/custom_text_field.dart';
import '../../../../../ui/ui.dart';
import '../../../onboarding/view/get_started_screen.dart' show isUserProvider;
import '../manager/auth_provuder.dart';
import '../view/widgets/country_code_button.dart';
import '../view/widgets/otp_bottom_sheet.dart';
import 'otp_register_page.dart';

final securePasswordProvider =
    StateProvider.family.autoDispose<bool, dynamic>((ref, _) => true);
final isRememberProvider = StateProvider.autoDispose<bool>((ref) => false);

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
        value: '+966',
        validators: [Validators.required],
      ),
      'phone': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(9),
          Validators.maxLength(15),
        ],
      ),
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
                  Assets.base.loginHero.path,
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
            bottom: MediaQuery.of(context).padding.bottom+30,
            left: 0,
            right: 0,
            child: ReactiveForm(
              formGroup: formGroup,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20).copyWith(bottom: 0),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CountryCodeButton(formGroup: formGroup),
                        const Gap(8),
                        Expanded(
                          child: CustomTextField(
                            radius: 16,
                            formControlName: "phone",
                            hintText: "Phone Number".tr,
                            inputType: TextInputType.phone,
                            inputFormatter: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            focusNode: phoneNode,
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
                            radius: 100,
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
                                  });
                                  if (preLoginResponse != null &&
                                      preLoginResponse.success) {
                                    if (preLoginResponse.data?.isNewUser ==
                                        true) {
                                      Get.to(() => OtpRegisterPage(
                                            phone: phoneNumber,
                                            countryCode: countryCode,
                                            otpAlreadySent: true,
                                          ));
                                      return;
                                    }
                                    if (!context.mounted) return;
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
                                              'code': otp,
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
                    const Gap(16),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xffE6E6E6))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Or'.tr,
                            style: AppFont.font14W600Grey2.copyWith(
                              fontSize: 18,
                              color: const Color(0xff666666),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xffE6E6E6))),
                      ],
                    ),
                    const Gap(10),
                    Center(
                      child: Text(
                        'Sign up with social media'.tr,
                        style: AppFont.font14W500Black.copyWith(
                          fontSize: 16,
                          color: const Color(0xff1A1A1A),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialCircle(
                          color: const Color(0xff4285F4),
                          child: SvgPicture.asset(
                            Assets.socialMedia.facebookSvg,
                            width: 20,
                            height: 20,
                          ),
                          onTap: () {},
                        ),
                        const Gap(20),
                        _SocialCircle(
                          color: const Color(0xff616161),
                          child: SvgPicture.asset(
                            Assets.socialMedia.appleSvg,
                            width: 20,
                            height: 20,
                          ),
                          onTap: () {},
                        ),
                        const Gap(20),
                        _SocialCircle(
                          color: Colors.white,
                          bordered: true,
                          child: SvgPicture.asset(
                            Assets.socialMedia.googleSvg,
                            width: 20,
                            height: 20,
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
                    const Gap(24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?".tr,
                          style: AppFont.font14W500Black.copyWith(
                            color: const Color(0xff515151),
                          ),
                        ),
                        const Gap(8),
                        GestureDetector(
                          onTap: () => Get.to(() => const OtpRegisterPage()),
                          child: Text(
                            'Sign up'.tr,
                            style: AppFont.font14W600Black.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

class _SocialCircle extends StatelessWidget {
  const _SocialCircle({
    required this.color,
    required this.child,
    required this.onTap,
    this.bordered = false,
  });

  final Color color;
  final Widget child;
  final VoidCallback onTap;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: bordered ? const Color(0xffEAEAEA) : Colors.transparent,
          ),
        ),
        child: child,
      ),
    );
  }
}
