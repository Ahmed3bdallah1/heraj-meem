import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import '../../managers/payment_type.dart';
import '../../managers/selection_providers.dart';

class PaymentSelector extends ConsumerWidget {
  const PaymentSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPaymentProvider);
    return Column(
      spacing: 10,
      children: [
        _tile(context, ref, PaymentType.Cash, selected),
        _tile(context, ref, PaymentType.Visa, selected),
      ],
    );
  }

  Widget _tile(BuildContext context, WidgetRef ref, PaymentType type, PaymentType group) {
    final isSelected = group == type;
    return GestureDetector(
      onTap: () {
        ref.read(selectedPaymentProvider.notifier).state = type;
      },
      child: Container(
        decoration: BoxDecoration(
            color: isSelected ? AppColor.primary.withAlpha(50) : AppColor.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColor.primary : AppColor.grey3,
              width: 1.5,
            )),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: SizedBox(
              width: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type.name.tr,
                    style: AppFont.font16W700Primary,
                  ),
                  Image.asset(
                    type.image,
                    height: 30,
                    width: 30,
                    fit: BoxFit.cover,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


