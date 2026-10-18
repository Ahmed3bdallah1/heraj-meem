import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../config/app_font.dart';
import '../../../../../core/service/localization_service/localization_service.dart';
import '../../../../../main.dart';
import '../../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../../categories/data/models/main_category_model.dart';
import '../../../../categories/presentation/managers/categories_provider.dart';

class SelectCategoryStep extends ConsumerStatefulWidget {
  final ValueChanged<CategoryModel> onCategorySelected;

  const SelectCategoryStep({super.key, required this.onCategorySelected});

  @override
  ConsumerState<SelectCategoryStep> createState() => _SelectCategoryStepState();
}

class _SelectCategoryStepState extends ConsumerState<SelectCategoryStep>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  CategoryModel? _selectedCategory;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final categoriesAsync = ref.watch(fetchFeaturedCategoriesProvider);
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search'.tr,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColor.primary2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Gap(16),
            categoriesAsync.when(
              data: (categories) {
                final mainCategories =
                    categories.where((c) => c.level == 1).toList();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: mainCategories.length,
                  itemBuilder: (context, index) {
                    final category = mainCategories[index];
                    final isSelected = _selectedCategory?.id == category.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        widget.onCategorySelected(category);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.primary2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColor.primary
                                : AppColor.primary2,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColor.primary2,
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: category.image != null ||
                                        category.image == ""
                                    ? ImageOrSvg(category.image!,
                                        fit: BoxFit.contain)
                                    : Icon(Icons.category,
                                        color: AppColor.primary),
                              ),
                            ),
                            const Gap(8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                langCode == 'ar'
                                    ? category.nameAr
                                    : langCode == 'tr'
                                        ? category.nameTr
                                        : category.name,
                                style: AppFont.font12w400Black,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading categories'.tr),
              ),
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}
