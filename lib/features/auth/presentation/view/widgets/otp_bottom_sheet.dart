import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../config/app_color.dart';
import '../../../../../config/app_font.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../../../ui/shared_widgets/custom_otp.dart';

final otpCodeProvider = StateProvider.autoDispose<String?>((ref) => null);

class OTPBottomSheet extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String countryCode;
  final bool isLoading;
  final Function(String otp) onVerify;
  final Function()? onResend;

  const OTPBottomSheet({
    super.key,
    required this.phoneNumber,
    required this.countryCode,
    required this.onVerify,
    this.onResend,
    this.isLoading = false,
  });

  @override
  ConsumerState<OTPBottomSheet> createState() => _OTPBottomSheetState();
}

class _OTPBottomSheetState extends ConsumerState<OTPBottomSheet> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _currentTimerValue = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _currentTimerValue = 30;
    setState(() {});

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _currentTimerValue--;
      if (_currentTimerValue >= 0) {
        Future.microtask(() {
          if (mounted) {
            setState(() {});
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _maskPhoneNumber(String phone, String countryCode) {
    if (phone.length <= 4) return phone;
    final lastFour = phone.substring(phone.length - 4);
    return '$countryCode ••••$lastFour';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpCode = ref.watch(otpCodeProvider);
    final canResend = _currentTimerValue == 0;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "OTP".tr,
                        style: AppFont.font24w600Black.copyWith(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Gap(16),
                  Text(
                    "We've sent a 6-digit code to your phone number".tr,
                    style: AppFont.font14W500Black.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const Gap(8),
                  Text(
                    _maskPhoneNumber(widget.phoneNumber, widget.countryCode),
                    textDirection: TextDirection.ltr,
                    style: AppFont.font14W600Black.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  const Gap(32),
                  CustomOTP(
                    controller: _otpController,
                    onChanged: (value) {
                      ref.read(otpCodeProvider.notifier).state = value;
                    },
                    onCompleted: (value) {
                      ref.read(otpCodeProvider.notifier).state = value;
                    },
                  ),
                  const Gap(24),
                  Center(
                    child: GestureDetector(
                      onTap: canResend
                          ? () {
                              if (widget.onResend != null) {
                                widget.onResend!();
                                _startTimer();
                              }
                            }
                          : null,
                      child: RichText(
                        text: TextSpan(
                          style: AppFont.font14W500Black.copyWith(
                            color: Colors.grey[600],
                          ),
                          children: [
                            TextSpan(text: "Didn't receive the code? ".tr),
                            TextSpan(
                              text: canResend
                                  ? "Resend".tr
                                  : "Resend in %ss".trParams(
                                      {"s": _currentTimerValue.toString()}),
                              style: AppFont.font14W600Black.copyWith(
                                color: canResend
                                    ? AppColor.primary
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Gap(24),
                  // Verify button
                  CustomFilledButton(
                    text: "Verify".tr,
                    isValid: otpCode != null && otpCode.length == 6,
                    isLoading: widget.isLoading,
                    onPressed: () {
                      if (otpCode != null && otpCode.length == 6) {
                        widget.onVerify(otpCode);
                      }
                    },
                    textSize: 16,
                    color: AppColor.primary,
                    fontColor: Colors.white,
                  ),
                  const Gap(16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
