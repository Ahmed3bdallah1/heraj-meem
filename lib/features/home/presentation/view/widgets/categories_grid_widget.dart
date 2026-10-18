import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/local_data_manager.dart';
import 'package:heraj_meem/features/categories/data/models/main_category_model.dart';
import 'package:heraj_meem/features/categories/presentation/view/all_categories_screen.dart';
import 'package:heraj_meem/features/categories/presentation/view/category_screen.dart';
import 'package:heraj_meem/features/categories/presentation/view/widgets/all_categories/category_icon_helper.dart';
import 'package:heraj_meem/helper/extensions/adaptive_view.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/shimmer_effect.dart';
import '../../managers/fetch_home_data_provider.dart';

class CategoriesGridWidget extends ConsumerWidget {
  const CategoriesGridWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(fetchHomeDataProvider);

    return provider.customWhen(
      ref: ref,
      refreshable: fetchHomeDataProvider.future,
      loading: () => _buildLoadingCategories(),
      data: (homeData) {
        final displayCategories = homeData.categories.take(8).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Browse Categories'.tr,
                    style: AppFont.font18W700Black,
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const AllCategoriesScreen()),
                    child: Text(
                      'See All'.tr,
                      style: AppFont.font14W600Primary,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(8),
            Padding(
              padding: context.responsiveHorizontalPadding(),
              child: MasonryGridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.adaptiveValue<int>(
                    mobile: 4,
                    tablet: 6,
                    desktop: 8,
                  ),
                ),
                itemCount: displayCategories.length,
                itemBuilder: (context, index) {
                  final category = displayCategories[index];
                  return _CategoryCard(category: category, index: index);
                },
              ),
            ),
            const Gap(16),
          ],
        );
      },
    );
  }

  Widget _buildLoadingCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
        children: List.generate(8, (index) {
          return Column(
            children: [
              ShimmerEffect(
                enable: true,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColor.grey1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const Gap(8),
              ShimmerEffect(
                enable: true,
                child: Container(
                  width: 50,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColor.grey1,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int index;

  const _CategoryCard({
    required this.category,
    required this.index,
  });

  String get categoryName {
    final languageCode = dataManager.getLanguage?.locale.languageCode ?? "en";
    return languageCode == "ar"
        ? category.nameAr
        : languageCode == "tr"
            ? category.nameTr
            : category.name;
  }

  Color get baseColor {
    if (category.icon != null && category.icon!.isNotEmpty) {
      return CategoryIconHelper.getCategoryColor(category.icon);
    }
    return CategoryIconHelper.getColorByName(category.name);
  }

  List<Color> get gradientColors {
    final hsl = HSLColor.fromColor(baseColor);
    final darkerColor =
        hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
    return [baseColor.withAlpha(200), darkerColor];
  }

  Color get lightBackgroundColor => baseColor.withAlpha(25);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: GestureDetector(
        onTap: () => Get.to(() => CategoryScreen(category: category)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: (category.icon != null && category.icon!.isNotEmpty)
                      ? CategoryIconHelper.getIcon(
                          category.icon,
                          color: Colors.white,
                          size: 24,
                        )
                      : CategoryIconHelper.getIconByName(
                          category.name,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                categoryName,
                style: AppFont.font10w400Black,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
