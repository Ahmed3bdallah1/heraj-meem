import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/gen/assets.gen.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../config/app_font.dart';
import '../../../../../helper/responsive.dart';
import '../../../../../ui/shared_widgets/custom_reactive_form_consumer.dart';
import '../../../../../ui/shared_widgets/custom_text_field.dart';
import '../../../../../ui/ui.dart';
import '../manager/auth_provuder.dart';
import 'widgets/country_code_button.dart';
import 'widgets/otp_bottom_sheet.dart';

class OtpRegisterPage extends ConsumerStatefulWidget {
  const OtpRegisterPage({
    super.key,
    this.phone,
    this.countryCode = '+966',
    this.otpAlreadySent = false,
  });

  final String? phone;
  final String countryCode;
  final bool otpAlreadySent;

  @override
  ConsumerState<OtpRegisterPage> createState() => _OtpRegisterPageState();
}

class _OtpRegisterPageState extends ConsumerState<OtpRegisterPage> {
  late final FormGroup formGroup;

  @override
  void initState() {
    super.initState();
    formGroup = FormGroup({
      'displayName': FormControl<String>(validators: [Validators.required]),
      'country_code': FormControl<String>(
        value: widget.countryCode.startsWith('+')
            ? widget.countryCode
            : '+${widget.countryCode}',
        validators: [Validators.required],
      ),
      'phone': FormControl<String>(
        value: widget.phone,
        validators: [
          Validators.required,
          Validators.minLength(9),
          Validators.maxLength(15),
        ],
      ),
    });
  }

  @override
  void dispose() {
    formGroup.dispose();
    super.dispose();
  }

  String get _countryCode =>
      formGroup.control('country_code').value as String? ?? widget.countryCode;

  Future<void> _openOtp(String phone) async {
    final displayName = formGroup.control('displayName').value as String;
    final countryCode = _countryCode;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => OTPBottomSheet(
        phoneNumber: phone,
        countryCode: countryCode,
        isLoading: ref.read(authNotifierProvider),
        onVerify: (otp) async {
          Navigator.pop(sheetContext);
          try {
            await ref.read(authNotifierProvider.notifier).register({
              'phone': phone,
              'countryCode': countryCode,
              'code': otp,
              'displayName': displayName,
            });
          } catch (e) {
            UIHelper.showAlert(e.toString(), type: DialogType.error);
          }
        },
        onResend: () async {
          await ref.read(authNotifierProvider.notifier).preLogin({
            'phone': phone,
            'countryCode': countryCode,
          });
        },
      ),
    );
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
            height: height * 0.42,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(Assets.base.loginHero.path, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(0),
                        Colors.black.withAlpha(77),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Image.asset(
                      Assets.base.logoWhite.path,
                      width: width * .4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: height * 0.28,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: ReactiveForm(
                formGroup: formGroup,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                  children: [
                    Text(
                      'Create account'.tr,
                      style: AppFont.font24w600Black.copyWith(
                        color: AppColor.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Please type your phone number'.tr,
                      style: AppFont.font14W500Black.copyWith(
                        color: const Color(0xff666666),
                      ),
                    ),
                    const Gap(20),
                    CustomTextField(
                      radius: 16,
                      formControlName: 'displayName',
                      hintText: 'Display name'.tr,
                    ),
                    const Gap(12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CountryCodeButton(
                          formGroup: formGroup,
                          enabled: !widget.otpAlreadySent,
                        ),
                        const Gap(8),
                        Expanded(
                          child: CustomTextField(
                            radius: 16,
                            formControlName: 'phone',
                            hintText: 'Phone Number'.tr,
                            inputType: TextInputType.phone,
                            ignore: widget.otpAlreadySent,
                            inputFormatter: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),
                    CustomReactiveFormValidationConsumer(
                      formGroup: formGroup,
                      builder: (context, _, child) {
                        final isLoading = ref.watch(authNotifierProvider);
                        return CustomFilledButton(
                          isLoading: isLoading,
                          isValid: formGroup.valid,
                          text: 'Sign up'.tr,
                          textSize: 16,
                          radius: 100,
                          color: AppColor.primary,
                          fontColor: Colors.white,
                          onPressed: () async {
                            if (!formGroup.valid) {
                              formGroup.markAllAsTouched();
                              return;
                            }
                            final phone =
                                formGroup.control('phone').value as String;
                            try {
                              if (!widget.otpAlreadySent) {
                                final sent = await ref
                                    .read(authNotifierProvider.notifier)
                                    .preLogin({
                                  'phone': phone,
                                  'countryCode': _countryCode,
                                });
                                if (sent == null || !sent.success) return;
                              }
                              if (!context.mounted) return;
                              await _openOtp(phone);
                            } catch (e) {
                              UIHelper.showAlert(
                                e.toString(),
                                type: DialogType.error,
                              );
                            }
                          },
                        );
                      },
                    ),
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
