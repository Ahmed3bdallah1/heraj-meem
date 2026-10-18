import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/local_data_manager.dart';
import 'package:heraj_meem/features/categories/data/models/main_category_model.dart';
import 'package:heraj_meem/features/categories/presentation/view/category_screen.dart';
import '../../../../../store/presentation/view/store_category_screen.dart';
import 'category_icon_helper.dart';

class CategoryTreeCard extends StatefulWidget {
  final CategoryModel category;
  final bool isOpenStore;

  const CategoryTreeCard({
    super.key,
    required this.category,
    this.isOpenStore = false,
  });

  @override
  State<CategoryTreeCard> createState() => _CategoryTreeCardState();
}

class _CategoryTreeCardState extends State<CategoryTreeCard> {
  final Map<String, bool> _subcategoryExpanded = {};
  bool _showAllSubcategories = false;
  bool _isHovered = false;

  String _getCategoryName(CategoryModel category) {
    final languageCode = dataManager.getLanguage?.locale.languageCode ?? "ar";
    if (languageCode == "ar") {
      return category.nameAr;
    } else if (languageCode == "en") {
      return category.name;
    } else {
      return category.nameTr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = CategoryIconHelper.getCategoryColor(widget.category.icon);
    final displayName = _getCategoryName(widget.category);
    final subcategories = widget.category.children;
    final visibleSubcategories =
        _showAllSubcategories ? subcategories : subcategories.take(4).toList();
    final remainingCount = _showAllSubcategories
        ? 0
        : (subcategories.length > 4 ? subcategories.length - 4 : 0);

    return GestureDetector(
      onTap: () {
        Get.to(() => widget.isOpenStore
            ? StoreCategoryScreen(widget.category)
            : CategoryScreen(category: widget.category));
      },
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isHovered ? 0.98 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColor.white,
        ),
        child: Container(
          decoration: BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     AppColor.white,
            //     iconColor.withAlpha(10),
            //   ],
            // ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: iconColor.withAlpha(100),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CategoryIconHelper.getIcon(
                          widget.category.icon,
                          color: iconColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        displayName,
                        style: AppFont.font14W700Black,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Subcategories list
              if (subcategories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ...visibleSubcategories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final subcategory = entry.value;
                        final isExpanded =
                            _subcategoryExpanded[subcategory.id] ?? false;
                        final itemCount = subcategory.children.length;

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 200 + (index * 50)),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: _SubcategoryItem(
                            key: ValueKey(subcategory.id),
                            subcategory: subcategory,
                            isExpanded: isExpanded,
                            isOpenStore: widget.isOpenStore,
                            itemCount: itemCount,
                            onToggle: () {
                              setState(() {
                                _subcategoryExpanded[subcategory.id] =
                                    !isExpanded;
                              });
                            },
                            onTap: () {
                              if (subcategory.children.isNotEmpty) {
                                setState(() {
                                  _subcategoryExpanded[subcategory.id] =
                                      !isExpanded;
                                });
                              } else {
                                print(widget.isOpenStore);
                                Get.to(() => widget.isOpenStore
                                    ? StoreCategoryScreen(subcategory)
                                    : CategoryScreen(category: subcategory));
                              }
                            },
                          ),
                        );
                      }),
                      if (remainingCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showAllSubcategories = true;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: AppColor.primary,
                                ),
                                const Gap(4),
                                Text(
                                  "+$remainingCount more".tr,
                                  style: AppFont.font12W600Primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              if (subcategories.isEmpty) const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubcategoryItem extends StatefulWidget {
  final CategoryModel subcategory;
  final bool isExpanded;
  final bool isOpenStore;
  final int itemCount;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _SubcategoryItem({
    super.key,
    required this.subcategory,
    required this.isExpanded,
    this.isOpenStore = false,
    required this.itemCount,
    required this.onToggle,
    required this.onTap,
  });

  @override
  State<_SubcategoryItem> createState() => _SubcategoryItemState();
}

class _SubcategoryItemState extends State<_SubcategoryItem>
    with SingleTickerProviderStateMixin {
  bool _showAllChildren = false;
  bool _isHovered = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  late Animation<double> _chevronRotationAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _chevronRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));

    if (widget.isExpanded) {
      _expandController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_SubcategoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  String _getCategoryName(CategoryModel category) {
    final languageCode = dataManager.getLanguage?.locale.languageCode ?? "ar";
    if (languageCode == "ar") {
      return category.nameAr;
    } else if (languageCode == "en") {
      return category.name;
    } else {
      return category.nameTr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _getCategoryName(widget.subcategory);
    final children = widget.subcategory.children;
    final visibleChildren =
        _showAllChildren ? children : children.take(8).toList();
    final remainingChildren =
        _showAllChildren ? 0 : (children.length > 8 ? children.length - 8 : 0);
    final hasChildren = children.isNotEmpty;

    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isHovered = true),
          onTapUp: (_) => setState(() => _isHovered = false),
          onTapCancel: () => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.identity()..scale(_isHovered ? 0.97 : 1.0),
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: widget.isExpanded && hasChildren
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF9B59B6),
                        const Color(0xFFE91E63),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: !widget.isExpanded || !hasChildren
                  ? (_isHovered
                      ? AppColor.primary2.withAlpha(75)
                      : Colors.transparent)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (hasChildren)
                  AnimatedBuilder(
                    animation: _chevronRotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _chevronRotationAnimation.value * 3.14159,
                        child: GestureDetector(
                          onTap: widget.onToggle,
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            size: 20,
                            color: widget.isExpanded
                                ? Colors.white
                                : AppColor.grey2,
                          ),
                        ),
                      );
                    },
                  )
                else
                  const SizedBox(width: 20),
                const Gap(8),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: widget.isExpanded && hasChildren
                        ? AppFont.font14W500White
                        : AppFont.font14W500Black,
                    child: Text(displayName),
                  ),
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: widget.isExpanded && hasChildren
                      ? AppFont.font14W500White
                      : AppFont.font12w500Grey2,
                  child: Text("(${widget.itemCount})"),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1.0,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: widget.isExpanded && children.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(left: 36, top: 4, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...visibleChildren.asMap().entries.map((entry) {
                          final index = entry.key;
                          final child = entry.value;
                          final childName = _getCategoryName(child);
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(
                              milliseconds: 200 + (index * 30),
                            ),
                            curve: Curves.easeOut,
                            builder: (context, value, childWidget) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(10 * (1 - value), 0),
                                  child: childWidget,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(() => widget.isOpenStore
                                      ? StoreCategoryScreen(child)
                                      : CategoryScreen(
                                          category: child));
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: AppColor.grey2,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      child: Text(
                                        childName,
                                        style: AppFont.font12w400Black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        if (remainingChildren > 0)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(
                              milliseconds: 200 + (visibleChildren.length * 30),
                            ),
                            curve: Curves.easeOut,
                            builder: (context, value, childWidget) {
                              return Opacity(
                                opacity: value,
                                child: childWidget,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showAllChildren = true;
                                  });
                                },
                                child: Row(
                                  children: [
                                    const Gap(12),
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 12,
                                      color: AppColor.primary,
                                    ),
                                    const Gap(4),
                                    Text(
                                      "+$remainingChildren more".tr,
                                      style: AppFont.font12W600Primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
