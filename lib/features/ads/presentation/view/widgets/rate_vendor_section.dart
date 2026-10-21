import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/domain/entities/rate_vendor_request.dart';
import 'package:heraj_meem/features/ads/domain/use_case/rate_vendor_use_case.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj_meem/ui/ui.dart';
import 'package:reactive_forms/reactive_forms.dart';

class RateVendorSection extends StatefulWidget {
  const RateVendorSection({
    super.key,
    required this.adId,
    required this.revieweeId,
  });

  final String adId;
  final String revieweeId;

  @override
  State<RateVendorSection> createState() => _RateVendorSectionState();
}

class _RateVendorSectionState extends State<RateVendorSection> {
  final rating = ValueNotifier(0);
  final submitted = ValueNotifier(false);
  final submitting = ValueNotifier(false);
  final commentFocus = FocusNode();
  late final FormGroup form = FormGroup({
    'comment': FormControl<String>(),
  });

  @override
  void dispose() {
    rating.dispose();
    submitted.dispose();
    submitting.dispose();
    commentFocus.dispose();
    form.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final stars = rating.value;
    if (stars < 1) {
      UIHelper.showGlobalSnackBar(
        text: 'Please select a rating'.tr,
        color: AppColor.danger,
      );
      return;
    }
    final sellerId = widget.revieweeId;
    if (sellerId.isEmpty) return;
    submitting.value = true;
    final result = await getIt<RateVendorUseCase>().call(
      RateVendorRequest(
        revieweeId: sellerId,
        adId: widget.adId,
        rating: stars,
        comment: form.control('comment').value?.toString().trim() ?? '',
      ),
    );
    if (!mounted) return;
    submitting.value = false;
    result.fold(
      (failure) => UIHelper.showGlobalSnackBar(
        text: failure.message,
        color: AppColor.danger,
      ),
      (_) => submitted.value = true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffE6E6E6)),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: submitted,
          builder: (context, done, _) {
            if (done) {
              return Text(
                'Thanks for your rating'.tr,
                style: AppFont.font14W600Black,
              );
            }
            return ReactiveForm(
              formGroup: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rate the vendor'.tr, style: AppFont.font14W700Black),
                  const Gap(4),
                  Text(
                    'How was the seller?'.tr,
                    style: AppFont.font12w400Black.copyWith(color: AppColor.grey2),
                  ),
                  const Gap(8),
                  ValueListenableBuilder<int>(
                    valueListenable: rating,
                    builder: (context, stars, _) {
                      return Row(
                        children: [
                          for (var index = 1; index <= 5; index++)
                            IconButton(
                              onPressed: () => rating.value = index,
                              icon: Icon(
                                index <= stars
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppColor.primary,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  ReactiveTextField<String>(
                    formControlName: 'comment',
                    focusNode: commentFocus,
                    textInputAction: TextInputAction.done,
                    minLines: 2,
                    maxLines: 4,
                    style: AppFont.font14W500Black,
                    onSubmitted: (_) => commentFocus.unfocus(),
                    decoration: InputDecoration(
                      labelText: 'Write a comment'.tr,
                      labelStyle: AppFont.labelTextField,
                      fillColor: AppColor.primary2,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColor.primary),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColor.primary),
                      ),
                    ),
                  ),
                  const Gap(12),
                  ValueListenableBuilder<bool>(
                    valueListenable: submitting,
                    builder: (context, isSubmitting, _) {
                      return CustomFilledButton(
                        text: 'Submit rating'.tr,
                        isLoading: isSubmitting,
                        radius: 12,
                        onPressed: isSubmitting ? null : _submit,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
