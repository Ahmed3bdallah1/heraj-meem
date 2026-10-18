import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj/ui/ui.dart';
import '../../managers/coupon_provider.dart';

class CouponInputWidget extends ConsumerStatefulWidget {
  const CouponInputWidget({super.key});

  @override
  ConsumerState<CouponInputWidget> createState() => _CouponInputWidgetState();
}

class _CouponInputWidgetState extends ConsumerState<CouponInputWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final couponCode = ref.read(couponCodeProvider);
      if (couponCode != null) {
        _controller.text = couponCode;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _applyCoupon(String code) async {
    if (code.isEmpty) return;

    try {
      ref.read(isLoadingProvider("applyCoupon").notifier).state = true;
      final couponAsync = ref.read(applyCouponProvider(code).future);
      final result = await couponAsync;

      result.fold(
        (failure) {
          UIHelper.showGlobalSnackBar(text: failure.message.tr, color: AppColor.danger2);
          ref.read(couponStateProvider.notifier).state = null;
          ref.read(couponCodeProvider.notifier).state = null;
        },
        (couponData) {
          ref.read(couponStateProvider.notifier).state = couponData;
          ref.read(couponCodeProvider.notifier).state = code;
          UIHelper.showGlobalSnackBar(text: "Coupon applied successfully".tr, color: AppColor.green);
        },
      );
    } finally {
      ref.read(isLoadingProvider("applyCoupon").notifier).state = false;
    }
  }

  void _removeCoupon() {
    ref.read(couponStateProvider.notifier).state = null;
    ref.read(couponCodeProvider.notifier).state = null;
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final couponState = ref.watch(couponStateProvider);
    final isLoading = ref.watch(isLoadingProvider("applyCoupon"));
    print(couponState == null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                readOnly: couponState != null,
                decoration: InputDecoration(
                  hintStyle: AppFont.font14W500Grey2,
                  labelStyle: AppFont.font16W700Primary,
                  hintText: "Enter coupon code".tr,
                  labelText: "Coupon Code".tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.grey1, width: 1),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.grey1, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColor.primary, width: 2),
                  ),
                  suffixIcon: couponState != null
                      ? IconButton(
                          icon: Icon(Icons.close, color: AppColor.grey2),
                          onPressed: _removeCoupon,
                        )
                      : null,
                ),
                style: AppFont.textFiled,
              ),
            ),
            const Gap(8),
            if (couponState == null)
              SizedBox(
                width: 100,
                child: CustomFilledButton(
                  text: "Apply".tr,
                  isLoading: isLoading,
                  onPressed: () {
                    final code = _controller.text.trim();
                    if (code.isNotEmpty) {
                      _applyCoupon(code);
                    }
                  },
                ),
              ),
          ],
        ),
        if (couponState != null) ...[
          const Gap(8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColor.primary),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColor.primary, size: 20),
                const Gap(8),
                Expanded(
                  child: Text(
                    "${"Coupon".tr}: ${couponState.coupon?.code ?? ''} - ${"Discount".tr}: \$${couponState.discount.toStringAsFixed(2)}",
                    style: AppFont.font14W600Black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
