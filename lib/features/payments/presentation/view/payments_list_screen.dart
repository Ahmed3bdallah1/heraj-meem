import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import '../managers/payments_provider.dart';
import 'widgets/payment_item_widget.dart';

class PaymentsListScreen extends ConsumerWidget {
  const PaymentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(fetchPaymentsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'My Payments'.tr,
          style: AppFont.font18W700Black,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchPaymentsProvider);
        },
        child: paymentsAsync.customWhen(
          ref: ref,
          refreshable: fetchPaymentsProvider.future,
          data: (paymentsData) {
            if (paymentsData.payments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: 64,
                      color: AppColor.grey2,
                    ),
                    const Gap(16),
                    Text(
                      'No payments found'.tr,
                      style: AppFont.font16W600Black.copyWith(
                        color: AppColor.grey2,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: paymentsData.payments.length,
              itemBuilder: (context, index) {
                final payment = paymentsData.payments[index];
                return PaymentItemWidget(payment: payment);
              },
            );
          },
          loading: () => _buildLoading(),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ShimmerEffect(
            enable: true,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}

