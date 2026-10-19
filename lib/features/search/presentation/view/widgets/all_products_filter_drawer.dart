import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/localization_service/localization_service.dart';
import 'package:heraj_meem/features/categories/presentation/managers/categories_provider.dart';
import 'package:heraj_meem/features/location/presentation/managers/location_provider.dart';
import 'package:heraj_meem/features/ads/presentation/managers/all_products_provider.dart';
import 'package:heraj_meem/features/search/presentation/managers/search_filter_notifier.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';

class AllProductsFilterDrawer extends ConsumerStatefulWidget {
  const AllProductsFilterDrawer({super.key});

  @override
  ConsumerState<AllProductsFilterDrawer> createState() =>
      _AllProductsFilterDrawerState();
}

class _AllProductsFilterDrawerState
    extends ConsumerState<AllProductsFilterDrawer> {
  String? selectedCategory;
  String? selectedCity;
  String? selectedCondition = 'All Conditions';
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filters = ref.read(searchFilterProvider);
    selectedCategory = filters['category'];
    selectedCity = filters['city'];
    selectedCondition = filters['condition'] ?? 'All Conditions';
    minPriceController.text = filters['minPrice']?.toString() ?? '';
    maxPriceController.text = filters['maxPrice']?.toString() ?? '';
  }

  @override
  void dispose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref
        .read(searchFilterProvider.notifier)
        .updateFilter('category', selectedCategory);
    ref.read(searchFilterProvider.notifier).updateFilter('city', selectedCity);
    ref.read(searchFilterProvider.notifier).updateFilter('condition',
        selectedCondition == 'All Conditions' ? null : selectedCondition);
    ref.read(searchFilterProvider.notifier).updateFilter(
          'minPrice',
          minPriceController.text.isNotEmpty
              ? double.tryParse(minPriceController.text)
              : null,
        );
    ref.read(searchFilterProvider.notifier).updateFilter(
          'maxPrice',
          maxPriceController.text.isNotEmpty
              ? double.tryParse(maxPriceController.text)
              : null,
        );
    ref.invalidate(allProductsNotifierProvider);
    Get.back();
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedCity = null;
      selectedCondition = 'All Conditions';
      minPriceController.clear();
      maxPriceController.clear();
    });
    ref.read(searchFilterProvider.notifier).clearFilters();
    ref.invalidate(allProductsNotifierProvider);
    Get.back();
  }

  void _setPriceRange(double? min, double? max) {
    setState(() {
      minPriceController.text = min?.toInt().toString() ?? '';
      maxPriceController.text =
          max != null && max < double.infinity ? max.toInt().toString() : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(fetchAllCategoriesProvider);
    final citiesAsync = ref.watch(fetchCitiesProvider);
    final currentLocale = localeService.getLocale();

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filters'.tr,
                    style: AppFont.font20W700Black,
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Filter Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categories Section
                    _buildSectionHeader(
                      icon: Icons.category_outlined,
                      title: 'Categories'.tr,
                      color: AppColor.primary,
                    ),
                    const Gap(12),
                    categoriesAsync.customWhen(
                      refreshable: fetchAllCategoriesProvider.future,
                      ref: ref,
                      data: (categories) => Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: AppColor.grey1.withAlpha(77),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: categories.map((category) {
                              return _buildCategoryItem(
                                category.name,
                                category.id,
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const Gap(24),

                    // Location Section
                    _buildSectionHeader(
                      icon: Icons.location_on_outlined,
                      title: 'Location'.tr,
                      color: AppColor.primary,
                    ),
                    const Gap(12),
                    citiesAsync.customWhen(
                      ref: ref,
                      refreshable: fetchCitiesProvider.future,
                      data: (citiesResponse) {
                        final cities = citiesResponse.cities;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColor.grey1.withAlpha(77),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'City'.tr,
                                style: AppFont.font14W600Black,
                              ),
                              const Gap(8),
                              DropdownButtonFormField<String>(
                                value: selectedCity,
                                decoration: InputDecoration(
                                  hintText: 'Select city'.tr,
                                  filled: true,
                                  fillColor: AppColor.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All Cities'.tr),
                                  ),
                                  ...cities.map((city) {
                                    return DropdownMenuItem(
                                      value: city.code,
                                      child: Text(
                                        city.getLocalizedName(
                                            currentLocale.name.toLowerCase()),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedCity = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      error: (_, __) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColor.grey1.withAlpha(77),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Error loading cities'.tr,
                          style: AppFont.font14W500Black.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const Gap(24),

                    // Condition Section
                    _buildSectionHeader(
                      icon: Icons.star_outline,
                      title: 'Condition'.tr,
                      color: AppColor.primary,
                    ),
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor.grey1.withAlpha(77),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildConditionButton('new'),
                          _buildConditionButton('used'),
                          _buildConditionButton('refurbished'),
                        ],
                      ),
                    ),
                    const Gap(24),

                    // Price Range Section
                    _buildSectionHeader(
                      icon: Icons.trending_up,
                      title: 'Price Range'.tr,
                      color: AppColor.primary,
                    ),
                    const Gap(12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColor.grey1.withAlpha(77),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Min'.tr,
                                      style: AppFont.font14W600Black,
                                    ),
                                    const Gap(8),
                                    TextFormField(
                                      controller: minPriceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        filled: true,
                                        fillColor: AppColor.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Max'.tr,
                                      style: AppFont.font14W600Black,
                                    ),
                                    const Gap(8),
                                    TextFormField(
                                      controller: maxPriceController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                        hintText: 'Any',
                                        filled: true,
                                        fillColor: AppColor.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildPriceRangeChip('Under ₺1K', 0, 1000),
                              _buildPriceRangeChip('₺1K - ₺5K', 1000, 5000),
                              _buildPriceRangeChip('₺5K - ₺10K', 5000, 10000),
                              _buildPriceRangeChip(
                                  'Over ₺10K', 10000, double.infinity),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomFilledButton(
                      text: 'Clear All'.tr,
                      color: AppColor.grey1,
                      fontColor: AppColor.danger,
                      onPressed: _clearFilters,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: CustomFilledButton(
                      text: 'Apply Filters'.tr,
                      color: AppColor.primary,
                      onPressed: _applyFilters,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const Gap(8),
        Text(
          title,
          style: AppFont.font16W700Black,
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String name, String id) {
    final isSelected = selectedCategory == id;
    return InkWell(
      onTap: () {
        setState(() {
          selectedCategory = isSelected ? null : id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary.withAlpha(26) : AppColor.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: AppFont.font14W500Black.copyWith(
                color: isSelected ? AppColor.primary : AppColor.black,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColor.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionButton(String condition) {
    final isSelected = selectedCondition == condition;
    return InkWell(
      onTap: () {
        setState(() {
          selectedCondition = condition;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primary : AppColor.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          condition.tr,
          style: AppFont.font14W600Black.copyWith(
            color: isSelected ? AppColor.white : AppColor.black,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeChip(String label, double min, double max) {
    return InkWell(
      onTap: () => _setPriceRange(min, max),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.primary.withAlpha(77)),
        ),
        child: Text(
          label,
          style: AppFont.font12W600Black.copyWith(
            color: AppColor.primary,
          ),
        ),
      ),
    );
  }
}
