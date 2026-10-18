import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/features/search/presentation/managers/search_filter_notifier.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_toggle_switch.dart';
import '../../../../../config/app_color.dart';
import '../../../../../config/app_font.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';

void showProductFilterBottomSheet(BuildContext context, WidgetRef ref) {
  final filters = ref.read(searchFilterProvider);

  final priceFromController = TextEditingController(text: filters['minPrice']?.toString() ?? '');
  final priceToController = TextEditingController(text: filters['maxPrice']?.toString() ?? '');

  String selectedSortType = filters['sort'] ?? '';
  bool? selectedFeatured = filters['featured'];

  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery
              .of(context)
              .viewInsets
              .bottom + 16,
        ),
        child: StatefulBuilder(builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Text(
                "Filter Products".tr,
                style: AppFont.font16W700Black,
              ),
              const Gap(20),

              // Price range
              Text("Price Range".tr, style: AppFont.font14W700Black),
              const Gap(8),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceFromController,
                        keyboardType: TextInputType.number,
                        style: AppFont.font14W600Black,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            hintText: "From".tr,
                            hintStyle: AppFont.font14W500Grey2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: TextFormField(
                        controller: priceToController,
                        style: AppFont.font14W600Black,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                            hintText: "To".tr,
                            hintStyle: AppFont.font14W500Grey2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(20),

              CustomToggleSwitch(
                labels: ["Featured".tr, "Not Featured".tr],
                index: selectedFeatured == null
                    ? 2
                    : selectedFeatured == true
                    ? 0
                    : 1,
                onToggle: (index) {
                  if (index == 0) {
                    setState(() {
                      selectedFeatured = true;
                    });
                  } else {
                    setState(() {
                      selectedFeatured = false;
                    });
                  }
                },
              ),
              const Gap(20),
              Text("Order by".tr, style: AppFont.font14W600Black),
              const Gap(8),
              Wrap(
                spacing: 8,
                children: [
                  ...OrderByTypes.values.map((element) {
                    return _GearTypeChip(
                      type: element,
                      isSelected: selectedSortType == element.sortValue,
                      onTap: () {
                        setState(() {
                          selectedSortType = element.sortValue;
                        });
                      },
                    );
                  })
                ],
              ),
              const Gap(30),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomFilledButton(
                      text: "Clear".tr,
                      color: AppColor.grey1,
                      fontColor: AppColor.danger,
                      onPressed: () {
                        ref.read(searchFilterProvider.notifier).clearFilters();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomFilledButton(
                      text: "Apply".tr,
                      color: AppColor.primary,
                      onPressed: () {
                        ref.read(searchFilterProvider.notifier).updateFilter(
                          'minPrice',
                          priceFromController.text.isNotEmpty
                              ? double.tryParse(priceFromController.text)
                              : null,
                        );
                        ref.read(searchFilterProvider.notifier).updateFilter(
                          'maxPrice',
                          priceToController.text.isNotEmpty
                              ? double.tryParse(priceToController.text)
                              : null,
                        );
                        ref.read(searchFilterProvider.notifier).updateFilter(
                          'featured',
                          selectedFeatured,
                        );
                        ref
                            .read(searchFilterProvider.notifier)
                            .updateFilter('sort', selectedSortType);

                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      );
    },
  );
}

class _GearTypeChip extends StatelessWidget {
  final OrderByTypes type;
  final bool isSelected;
  final VoidCallback onTap;

  const _GearTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      backgroundColor: Get.isDarkMode ? AppColor.mineShaft : Colors.white,
      label: Text(
        type.name.tr,
        style: isSelected ? AppFont.font12W700Primary : AppFont.font12W600Grey2,
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColor.primary.withAlpha(40),
      labelStyle: TextStyle(
        color: isSelected ? AppColor.primary : AppColor.black,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: AppColor.primary.withAlpha(125)),
    );
  }
}
