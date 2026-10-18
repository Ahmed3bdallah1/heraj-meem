import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../config/app_font.dart';

class FilterDrawer extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterDrawer({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late String selectedSort;
  late RangeValues priceRange;
  int? selectedRating;

  final List<Map<String, String>> sortOptions = [
    {'value': '-createdAt', 'label': 'Newest'},
    {'value': 'createdAt', 'label': 'Oldest'},
    {'value': '-price', 'label': 'Price: High to Low'},
    {'value': 'price', 'label': 'Price: Low to High'},
    {'value': '-rating', 'label': 'Rating: High to Low'},
  ];

  @override
  void initState() {
    super.initState();
    selectedSort = widget.currentFilters['sort'] ?? '-createdAt';
    priceRange = RangeValues(
      double.tryParse(widget.currentFilters['minPrice']?.toString() ?? '0') ?? 0,
      double.tryParse(widget.currentFilters['maxPrice']?.toString() ?? '50000') ?? 50000,
    );
    selectedRating = widget.currentFilters['minRating'] != null
        ? int.tryParse(widget.currentFilters['minRating'].toString())
        : null;
  }

  void _resetFilters() {
    setState(() {
      selectedSort = '-createdAt';
      priceRange = const RangeValues(0, 50000);
      selectedRating = null;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    
    if (selectedSort != '-createdAt') {
      filters['sort'] = selectedSort;
    }
    
    if (priceRange.start > 0) {
      filters['minPrice'] = priceRange.start.toStringAsFixed(0);
    }
    
    if (priceRange.end < 50000) {
      filters['maxPrice'] = priceRange.end.toStringAsFixed(0);
    }
    
    if (selectedRating != null) {
      filters['minRating'] = selectedRating.toString();
    }

    widget.onApplyFilters(filters);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: AppColor.primary,
                      size: 24,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    'Filters'.tr,
                    style: AppFont.font20W700Black,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort By Section
                  Row(
                    children: [
                      Icon(Icons.sort, size: 20, color: AppColor.primary),
                      const Gap(8),
                      Text(
                        'Sort By'.tr,
                        style: AppFont.font16W700Black,
                      ),
                    ],
                  ),
                  const Gap(12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSort,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: AppColor.primary),
                        style: AppFont.font14W600Black,
                        dropdownColor: Colors.white,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedSort = newValue;
                            });
                          }
                        },
                        items: sortOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(option['label']!.tr),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const Gap(24),

                  // Price Range Section
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 20, color: AppColor.primary),
                      const Gap(8),
                      Text(
                        'Price Range'.tr,
                        style: AppFont.font16W700Black,
                      ),
                    ],
                  ),
                  const Gap(12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '৳${priceRange.start.toStringAsFixed(2)}',
                              style: AppFont.font14W600Black.copyWith(
                                color: AppColor.primary,
                              ),
                            ),
                            Text(
                              '৳${priceRange.end.toStringAsFixed(2)}',
                              style: AppFont.font14W600Black.copyWith(
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                        RangeSlider(
                          values: priceRange,
                          min: 0,
                          max: 50000,
                          divisions: 100,
                          activeColor: AppColor.primary,
                          inactiveColor: AppColor.primary.withAlpha(51),
                          onChanged: (RangeValues values) {
                            setState(() {
                              priceRange = values;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const Gap(24),

                  // Minimum Rating Section
                  Row(
                    children: [
                      Icon(Icons.star, size: 20, color: AppColor.primary),
                      const Gap(8),
                      Text(
                        'Minimum Rating'.tr,
                        style: AppFont.font16W700Black,
                      ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      final rating = index + 1;
                      final isSelected = selectedRating == rating;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedRating = isSelected ? null : rating;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColor.primary
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColor.primary
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 24,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[400],
                                  ),
                                  const Gap(4),
                                  Text(
                                    '$rating+',
                                    style: AppFont.font12W600Black.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const Gap(24),

                  // Reset All Filters Button
                  OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColor.primary,
                      side: BorderSide(color: AppColor.primary, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 20, color: AppColor.primary),
                        const Gap(8),
                        Text(
                          'Reset All Filters'.tr,
                          style: AppFont.font16W600Black.copyWith(
                            color: AppColor.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply Filters Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, size: 20),
                  const Gap(8),
                  Text(
                    'Apply Filters'.tr,
                    style: AppFont.font16W700Black.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

