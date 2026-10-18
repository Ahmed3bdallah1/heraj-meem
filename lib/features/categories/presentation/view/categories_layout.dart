import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/categories/data/models/main_category_model.dart';
import 'package:heraj/features/categories/domain/entites/sub_category.dart';
import 'package:heraj/features/categories/presentation/view/category_screen.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:logger/logger.dart';
import '../../../../core/service/local_data_manager.dart';
import '../../../store/presentation/view/store_category_screen.dart';

class CategoryIconItem extends StatelessWidget {
  final CategoryModel category;
  final bool isOpenStore;
  final bool isNew;

  const CategoryIconItem({super.key, required this.category, this.isOpenStore = false, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    final languageCode = dataManager.getLanguage?.locale.languageCode ?? "ar";
    return GestureDetector(
      onTap: () => Get.to(() => isOpenStore
          ? StoreCategoryScreen(category)
          : CategoryScreen(category: category)),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColor.primary2,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: category.image != null
                        ? ImageOrSvg(
                            category.image,
                            fit: BoxFit.fill,
                          )
                        : category.icon != null
                            ? ImageOrSvg(
                                category.icon,
                                fit: BoxFit.fill,
                              )
                            : Icon(
                                Icons.category,
                                color: AppColor.grey2,
                                size: 32,
                              ),
                  ),
                ),
              ),
              if (isNew)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'New',
                    style: AppFont.font10W600White,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          SizedBox(
            width: 70,
            child: Text(
              languageCode == "ar"
                  ? category.nameAr
                  : languageCode == "en"
                      ? category.name
                      : category.nameTr,
              style: AppFont.font12w400Black,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class SubCategoriesLayout extends ConsumerWidget {
  final List<SubCategory> subCategories;

  const SubCategoriesLayout(this.subCategories, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: MasonryGridView.builder(
        padding: EdgeInsets.zero,
        itemCount: subCategories.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          final subCategory = subCategories[index];
          return SubCategoryWidget(subCategory: subCategory);
        },
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
    required this.category,
  });

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: InkWell(
              onTap: () => Get.to(() => CategoryScreen(category: category)),
              child: Container(
                height: 58,
                width: MediaQuery.of(context).size.width / 2 - 25,
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColor.black.withAlpha(40),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: AppFont.font12w400Black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 25,
            height: 56,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImageOrSvg(
                category.image ?? "",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubCategoryWidget extends StatelessWidget {
  const SubCategoryWidget({
    super.key,
    required this.subCategory,
  });

  final SubCategory subCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              height: 58,
              width: MediaQuery.of(context).size.width / 2 - 25,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.black.withAlpha(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        subCategory.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: AppFont.font12w400Black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: 25,
            height: 56,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ImageOrSvg(
                subCategory.image ?? "",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
