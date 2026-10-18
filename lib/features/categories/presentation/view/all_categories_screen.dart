import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/booking/presentation/view/booking_screen.dart';
import 'package:heraj/features/categories/data/models/main_category_model.dart';
import 'package:heraj/features/categories/presentation/managers/categories_provider.dart';
import 'package:heraj/features/categories/presentation/view/category_screen.dart';
import 'package:heraj/features/store/presentation/view/store_category_screen.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import '../../../../core/service/localization_service/localization_service.dart';
import '../../../../main.dart';

class AllCategoriesScreen extends ConsumerStatefulWidget {
  final bool isOpenStore;
  final bool isFromDrawer;

  const AllCategoriesScreen({super.key, this.isOpenStore = false, this.isFromDrawer = false});

  @override
  ConsumerState<AllCategoriesScreen> createState() =>
      _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends ConsumerState<AllCategoriesScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _backgroundAnimationController;
  final Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryModel> _filterCategories(
    List<CategoryModel> categories,
    String query,
  ) {
    if (query.isEmpty) return categories;

    final lowerQuery = query.toLowerCase();
    return categories.where((category) {
      return category.name.toLowerCase().contains(lowerQuery) ||
          category.nameTr.toLowerCase().contains(lowerQuery) ||
          category.nameAr.contains(lowerQuery) ||
          category.slug.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    final provider = widget.isOpenStore
        ? ref.watch(fetchAdminCategoriesTreeProvider)
        : ref.watch(fetchCategoriesTreeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  Text(
                    'Categories'.tr,
                    style: AppFont.font20W700Black,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: provider.customWhen(
              ref: ref,
              refreshable: widget.isOpenStore
                  ? fetchAdminCategoriesTreeProvider.future
                  : fetchCategoriesTreeProvider.future,
              data: (categories) {
                final filteredCategories = _filterCategories(
                  categories,
                  _searchQuery,
                );

                if (filteredCategories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const Gap(24),
                        Text(
                          _searchQuery.isEmpty
                              ? "No Categories".tr
                              : "No Results Found".tr,
                          style: AppFont.font18W700Black,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(8),
                        Text(
                          _searchQuery.isEmpty
                              ? "There are no categories available.".tr
                              : "Try a different search term.".tr,
                          style: AppFont.font14W500Black.copyWith(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom+20),
                  itemCount:
                      _buildCategoryList(filteredCategories, langCode).length +
                          1,
                  separatorBuilder: (context, index) => DottedDivider(),
                  itemBuilder: (context, index) {
                    // "All" item
                    if (index == 0) {
                      return _CategoryListItem(
                        icon: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.layers,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        title: 'All'.tr,
                        onTap: () {
                          Get.back();
                        },
                        showArrow: false,
                      );
                    }

                    final items =
                        _buildCategoryList(filteredCategories, langCode);
                    final item = items[index - 1];

                    return item;
                  },
                );
              },
            ),
          ),
          if(widget.isFromDrawer)
            Gap(context.mediaQueryPadding.bottom)
        ],
      ),
    );
  }

  List<Widget> _buildCategoryList(
      List<CategoryModel> categories, String langCode) {
    final List<Widget> items = [];

    for (final category in categories) {
      final isExpanded = _expandedCategories.contains(category.id);
      final hasChildren = category.children.isNotEmpty;
      final categoryName = langCode == "ar"
          ? category.nameAr
          : langCode == "en"
              ? category.name
              : category.nameTr;

      // Parent category
      items.add(
        _CategoryListItem(
          icon: category.image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ImageOrSvg(
                    category.image!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      category.icon ?? '📦',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
          title: categoryName,
          onTap: () {
            if (hasChildren) {
              _toggleCategory(category.id);
            } else {
              if (widget.isOpenStore) {
                Get.to(() => StoreCategoryScreen(category));
              } else {
                Get.to(() => CategoryScreen(category: category));
              }
            }
          },
          showArrow: hasChildren,
          isExpanded: isExpanded,
        ),
      );

      // Subcategories (if expanded)
      if (isExpanded && hasChildren) {
        for (final child in category.children) {
          final childName = langCode == "ar"
              ? child.nameAr
              : langCode == "en"
                  ? child.name
                  : child.nameTr;

          items.add(
            _CategoryListItem(
              icon: child.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ImageOrSvg(
                        child.image!,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          child.icon ?? '📦',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
              title: childName,
              onTap: () {
                if (widget.isOpenStore) {
                  Get.to(() => StoreCategoryScreen(child));
                } else {
                  Get.to(() => CategoryScreen(category: child));
                }
              },
              isSubcategory: true,
              showArrow: true,
            ),
          );
        }
      }
    }

    return items;
  }
}

class _CategoryListItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;
  final bool showArrow;
  final bool isExpanded;
  final bool isSubcategory;

  const _CategoryListItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.showArrow = true,
    this.isExpanded = false,
    this.isSubcategory = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: isSubcategory ? 32 : 16,
          right: 16,
          top: 12,
          bottom: 12,
        ),
        color: isSubcategory ? Colors.grey[50] : Colors.white,
        child: Row(
          children: [
            icon,
            Gap(isSubcategory ? 12 : 16),
            Expanded(
              child: Text(
                title,
                style: isSubcategory
                    ? AppFont.font14W600Black.copyWith(
                        color: Colors.grey[700],
                      )
                    : AppFont.font16W600Black,
              ),
            ),
            if (showArrow)
              Icon(
                isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
