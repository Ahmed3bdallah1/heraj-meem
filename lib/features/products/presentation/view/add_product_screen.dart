import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/config/app_string.dart';
import 'package:heraj/features/notifications/presentation/view/notifications_screen.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'add_product_components/ad_details_component.dart';
import 'add_product_components/ad_pending_component.dart';
import 'add_product_components/select_category_compnents.dart';
import 'add_product_components/select_city_component.dart';
import 'add_product_components/add_product_mixin.dart';

final addProductStepIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen>
    with AddProductMixin {

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  void showProductInfoBottomSheet(
      BuildContext context, Map<String, dynamic> productData) {
    final product = productData['product'] as Map<String, dynamic>?;
    if (product == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductInfoBottomSheet(product: product),
    );
  }

  Widget _buildProgressIndicator(int index) {
    return _ProgressIndicatorItem(index: index);
  }

  Widget _buildStepTitle(int index) {
    return _StepTitleItem(
      index: index,
      getStepTitle: getStepTitle,
    );
  }

  Widget _buildContinueButton() {
    return Consumer(
      builder: (context, ref, child) {
        final currentStep = ref.watch(addProductStepIndexProvider);
        if (currentStep >= 3) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => handleContinueButton(ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                currentStep == 2 ? 'Create New Ad'.tr : 'Continue'.tr,
                style: AppFont.font16W600Black.copyWith(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => handleBackButton(ref),
        ),
        title: Text(
          'Add Ad'.tr,
          style: AppFont.font16W700Black,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Get.to(()=> const NotificationsScreen());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(4, (index) => _buildProgressIndicator(index)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) => _buildStepTitle(index)),
            ),
          ),
          const Gap(16),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                ref.read(addProductStepIndexProvider.notifier).state = index;
              },
              children: [
                SelectCityStep(
                  selectedCity: selectedCity,
                  selectedDistrict: selectedDistrict,
                  selectedNeighborhood: selectedNeighborhood,
                  onCitySelected: onCitySelected,
                  onDistrictSelected: onDistrictSelected,
                  onNeighborhoodSelected: onNeighborhoodSelected,
                ),
                SelectCategoryStep(
                  onCategorySelected: onCategorySelected,
                ),
                AdDetailsStep(
                  titleController: titleController,
                  priceController: priceController,
                  descriptionController: descriptionController,
                  stockController: stockController,
                  selectedImages: selectedImages,
                  adType: adType,
                  productType: productType,
                  variants: variants,
                  onAdTypeChanged: onAdTypeChanged,
                  onProductTypeChanged: onProductTypeChanged,
                  onImagesPicked: pickImages,
                  onImageRemoved: removeImage,
                  onVariantsChanged: onVariantsChanged,
                ),
                AdPendingStep(
                  productData: createdProductData,
                  onViewAd: () {
                    if (createdProductData != null) {
                      showProductInfoBottomSheet(context, createdProductData!);
                    }
                  },
                ),
              ],
            ),
          ),
          _buildContinueButton(),
        ],
      ),
    );
  }
}

class _ProgressIndicatorItem extends ConsumerWidget {
  final int index;

  const _ProgressIndicatorItem({required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(addProductStepIndexProvider);
    final isCompleted = index <= currentStep;
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: isCompleted ? AppColor.primary : AppColor.grey1,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (index < 3) const Gap(8),
        ],
      ),
    );
  }
}

class _StepTitleItem extends ConsumerWidget {
  final int index;
  final String Function(int) getStepTitle;

  const _StepTitleItem({
    required this.index,
    required this.getStepTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(addProductStepIndexProvider);
    final isCompleted = index <= currentStep;
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? AppColor.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? AppColor.primary : AppColor.grey1,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          const Gap(4),
          Flexible(
            child: Text(
              getStepTitle(index),
              style: AppFont.font10w400Black.copyWith(
                color: isCompleted ? AppColor.primary : AppColor.grey2,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductInfoBottomSheet extends StatelessWidget {
  final Map<String, dynamic> product;

  const _ProductInfoBottomSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColor.grey1,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Product Information'.tr,
                      style: AppFont.font18W700Black,
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColor.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Images
                      if (product['images'] != null &&
                          (product['images'] as List).isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (product['images'] as List).length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 8),
                                width: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColor.grey1),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ImageOrSvg(
                                    (product['images'] as List)[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const Gap(20),
                      // Title
                      Text(
                        product['title']?.toString() ?? '',
                        style: AppFont.font20W700Black,
                      ),
                      const Gap(12),
                      // Price
                      Row(
                        children: [
                          Text(
                            '${'Price'.tr}: ',
                            style: AppFont.font16W600Black,
                          ),
                          Text(
                            '${product['price']?.toString() ?? '0'}${AppString.currency}',
                            style: AppFont.font18W700Black
                                .copyWith(color: AppColor.primary),
                          ),
                        ],
                      ),
                      const Gap(12),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: product['status'] == 'pending'
                              ? Colors.orange.withAlpha(50)
                              : product['status'] == 'approved'
                                  ? Colors.green.withAlpha(50)
                                  : AppColor.grey1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product['status']?.toString().toUpperCase() ?? '',
                          style: AppFont.font14W600Black.copyWith(
                            color: product['status'] == 'pending'
                                ? Colors.orange
                                : product['status'] == 'approved'
                                    ? Colors.green
                                    : AppColor.grey2,
                          ),
                        ),
                      ),
                      const Gap(16),
                      if (product['condition'] != null)
                        Row(
                          children: [
                            Text(
                              '${'Condition'.tr}: ',
                              style: AppFont.font14W600Black,
                            ),
                            Text(
                              product['condition']?.toString().toUpperCase() ??
                                  '',
                              style: AppFont.font14W500Black,
                            ),
                          ],
                        ),
                      const Gap(12),
                      Row(
                        children: [
                          Text(
                            '${'Stock'.tr}: ',
                            style: AppFont.font14W600Black,
                          ),
                          Text(
                            product['stock']?.toString() ?? '0',
                            style: AppFont.font14W500Black,
                          ),
                        ],
                      ),
                      const Gap(12),
                      if (product['productType'] != null)
                        Row(
                          children: [
                            Text(
                              '${'Product Type'.tr}: ',
                              style: AppFont.font14W600Black,
                            ),
                            Text(
                              product['productType']?.toString() ?? '',
                              style: AppFont.font14W500Black,
                            ),
                          ],
                        ),
                      const Gap(16),
                      if (product['description'] != null &&
                          product['description'].toString().isNotEmpty) ...[
                        Text(
                          'Product Description'.tr,
                          style: AppFont.font16W700Black,
                        ),
                        const Gap(8),
                        HtmlWidget(
                          product['description']?.toString() ?? '',
                          textStyle: AppFont.font14W500Black,
                        ),
                        const Gap(16),
                      ],
                      if (product['variants'] != null &&
                          (product['variants'] as List).isNotEmpty) ...[
                        Text(
                          'Variants'.tr,
                          style: AppFont.font16W700Black,
                        ),
                        const Gap(8),
                        ...(product['variants'] as List).map((variant) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                variant['name']?.toString() ?? '',
                                style: AppFont.font14W600Black,
                              ),
                              subtitle: Text(
                                (variant['options'] as List?)?.join(', ') ?? '',
                                style: AppFont.font12w400Black,
                              ),
                            ),
                          );
                        }),
                        const Gap(16),
                      ],
                      // Created Date
                      Row(
                        children: [
                          Text(
                            '${'Created At'.tr}: ',
                            style: AppFont.font14W600Black,
                          ),
                          Expanded(
                            child: Text(
                              product['createdAt']?.toString() ?? '',
                              style: AppFont.font12w400Black,
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
