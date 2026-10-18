import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/plans/data/models/plans_model.dart';
import 'package:heraj_meem/features/plans/presentation/managers/plans_provider.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';

final selectedPlanProvider = StateProvider<PlanModel?>((ref) => null);

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansProvider = ref.watch(fetchPlansProvider);
    final subscriptionProvider = ref.watch(fetchMySubscriptionProvider);
    final selectedPlan = ref.watch(selectedPlanProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Price Plan".tr,
          style: AppFont.font18W700Black,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(fetchPlansProvider);
            ref.invalidate(fetchMySubscriptionProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                subscriptionProvider.customWhen(
                  ref: ref,
                  refreshable: fetchMySubscriptionProvider.future,
                  data: (subscription) {
                    if (subscription.currentSubscription != null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Current Subscription".tr,
                            style: AppFont.font18W700Black,
                          ),
                          const Gap(12),
                          PlanCard(
                            planModel: subscription.currentSubscription!,
                            isCurrent: true,
                          ),
                          const Gap(30),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                // Subscription History Section
                subscriptionProvider.customWhen(
                  ref: ref,
                  refreshable: fetchMySubscriptionProvider.future,
                  data: (subscription) {
                    if (subscription.history.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Subscription History".tr,
                            style: AppFont.font18W700Black,
                          ),
                          const Gap(12),
                          ...subscription.history.map((plan) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: PlanCard(
                                  planModel: plan,
                                  isHistory: true,
                                ),
                              )),
                          const Gap(30),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                // Available Plans Section
                Text(
                  "Available Plans".tr,
                  style: AppFont.font18W700Black,
                ),
                const Gap(12),
                plansProvider.customWhen(
                  ref: ref,
                  refreshable: fetchPlansProvider.future,
                  data: (plans) {
                    return ListView.separated(
                      cacheExtent: 200,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => PlanCard(
                        planModel: plans[index],
                      ),
                      separatorBuilder: (_, __) => const Gap(10),
                      itemCount: plans.length,
                    );
                  },
                ),
                const Gap(30),
                Text(
                  "Choose Your Pricing Plan".tr,
                  style: AppFont.font18W700Black,
                ),
                if (selectedPlan != null) ...[
                  const Gap(12),
                  // Display features from the features array
                  ...selectedPlan.features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FeatureItem(
                          text: feature,
                          isNew: false,
                        ),
                      )),
                ],
                const Gap(20),
                CustomFilledButton(
                  onPressed: () {},
                  text: "Choose Plan".tr,
                  textSize: 16,
                ),
                const Gap(40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlanCard extends ConsumerWidget {
  final PlanModel planModel;
  final bool isCurrent;
  final bool isHistory;

  const PlanCard({
    super.key,
    required this.planModel,
    this.isCurrent = false,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = !isCurrent && !isHistory && 
        ref.watch(selectedPlanProvider)?.hashCode == planModel.hashCode;
    return GestureDetector(
      onTap: isCurrent || isHistory
          ? null
          : () => ref.read(selectedPlanProvider.notifier).state = planModel,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCurrent
                ? const Color(0xffF29B0F)
                : (isSelected
                    ? const Color(0xffF29B0F)
                    : Colors.grey.shade200),
            width: isCurrent ? 2 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 3),
              blurRadius: 10,
              color: Colors.black.withAlpha(20),
            ),
          ],
        ),
        child: Row(
          children: [
            if (planModel.icon != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (planModel.colorHex != null
                          ? Color(planModel.colorHex!)
                          : const Color(0xffF29B0F)).withAlpha(150),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Image.asset(planModel.icon!),
              )
            else
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffF29B0F).withAlpha(150),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.star, color: Colors.white),
              ),
            const Gap(15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        planModel.title,
                        style: AppFont.font16W700Black,
                      ),
                      const Gap(7),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffF29B0F),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Active".tr,
                            style: AppFont.font12W600Primary.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        )
                      else if (planModel.popular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffFFF2D9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Popular".tr,
                            style: AppFont.font12W600Primary,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    planModel.getDisplayDescription(),
                    style: AppFont.font14W500Black.copyWith(
                      color: Colors.grey.shade700
                    ),
                  )
                ],
              ),
            ),

            if (planModel.price == 0)
              Text(
                "Free".tr,
                style: AppFont.font16W700Primary,
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${planModel.getCurrencySymbol()}${planModel.price.toStringAsFixed(2)}",
                    style: AppFont.font16W700Primary,
                  ),
                  Text(
                    "/${planModel.period}",
                    style: AppFont.font12w500Grey2.copyWith(
                      color: Colors.grey.shade500
                    )
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
class FeatureItem extends StatelessWidget {
  final String text;
  final bool isNew;

  const FeatureItem({
    super.key,
    required this.text,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xffF29B0F), size: 22),
        const Gap(12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(4),
        if (isNew)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xffFFE7C3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "New!".tr,
              style: AppFont.font12W600Primary,
            ),
          )
      ],
    );
  }
}

