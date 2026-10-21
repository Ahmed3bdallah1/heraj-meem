import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/categories/data/models/main_category_model.dart';
import 'package:heraj_meem/features/categories/presentation/managers/categories_provider.dart';
import 'package:heraj_meem/features/categories/presentation/view/category_screen.dart';
import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/store/presentation/view/store_category_screen.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:substring_highlight/substring_highlight.dart';
import '../../../../core/service/localization_service/localization_service.dart';
import '../../../../main.dart';

class AllCategoriesScreen extends ConsumerStatefulWidget {
  final bool isOpenStore;
  final bool isFromDrawer;
  final bool isRootTab;

  const AllCategoriesScreen({
    super.key,
    this.isOpenStore = false,
    this.isFromDrawer = false,
    this.isRootTab = false,
  });

  @override
  ConsumerState<AllCategoriesScreen> createState() =>
      _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends ConsumerState<AllCategoriesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ValueNotifier<String> _query = ValueNotifier('');
  final ValueNotifier<Set<String>> _expanded = ValueNotifier({});
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _glow.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _query.dispose();
    _expanded.dispose();
    super.dispose();
  }

  List<CategoryModel> _filterCategories(
    List<CategoryModel> categories,
    String query,
  ) {
    if (query.isEmpty) return categories;
    final lowerQuery = query.toLowerCase();
    return categories.where((category) {
      final own = category.name.toLowerCase().contains(lowerQuery) ||
          category.nameTr.toLowerCase().contains(lowerQuery) ||
          category.nameAr.contains(lowerQuery) ||
          category.slug.toLowerCase().contains(lowerQuery);
      if (own) return true;
      return category.children.any((child) =>
          child.name.toLowerCase().contains(lowerQuery) ||
          child.nameTr.toLowerCase().contains(lowerQuery) ||
          child.nameAr.contains(lowerQuery) ||
          child.slug.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  void _toggleCategory(String categoryId) {
    final next = {..._expanded.value};
    if (!next.add(categoryId)) next.remove(categoryId);
    _expanded.value = next;
  }

  void _openCategory(CategoryModel category) {
    if (widget.isOpenStore) {
      Get.to(() => StoreCategoryScreen(category));
    } else {
      Get.to(() => CategoryScreen(category: category));
    }
  }

  String _name(CategoryModel category, String langCode) {
    if (langCode == 'ar') return category.nameAr;
    if (langCode == 'en') return category.name;
    return category.nameTr;
  }

  @override
  Widget build(BuildContext context) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    final provider = widget.isRootTab
        ? ref.watch(bahoCategoryModelsProvider)
        : widget.isOpenStore
            ? ref.watch(fetchAdminCategoriesTreeProvider)
            : ref.watch(fetchCategoriesTreeProvider);
    final refreshable = widget.isRootTab
        ? bahoCategoryModelsProvider.future
        : widget.isOpenStore
            ? fetchAdminCategoriesTreeProvider.future
            : fetchCategoriesTreeProvider.future;
    final bottomInset = MediaQuery.of(context).padding.bottom +
        (widget.isRootTab ? 110 : 20);

    return Scaffold(
      body: Column(
        children: [
          _CategoriesHeader(
            glow: _glow,
            showClose: !widget.isRootTab,
            searchController: _searchController,
            searchFocus: _searchFocus,
            onQuery: (value) => _query.value = value.trim().toLowerCase(),
          ),
          Expanded(
            child: provider.customWhen(
              ref: ref,
              refreshable: refreshable,
              loading: () => _CategoriesLoading(
                bottomInset: bottomInset,
                showAllTile: !widget.isRootTab,
              ),
              data: (categories) {
                return ValueListenableBuilder<String>(
                  valueListenable: _query,
                  builder: (context, query, _) {
                    final filtered = _filterCategories(categories, query);
                    if (filtered.isEmpty) {
                      return _EmptyCategories(hasQuery: query.isNotEmpty);
                    }
                    return ValueListenableBuilder<Set<String>>(
                      valueListenable: _expanded,
                      builder: (context, expanded, _) {
                        return ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset),
                          itemCount: filtered.length + (widget.isRootTab ? 0 : 1),
                          itemBuilder: (context, index) {
                            if (!widget.isRootTab && index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _Reveal(
                                  index: 0,
                                  child: _AllCategoriesTile(
                                    onTap: () => Get.back(),
                                  ),
                                ),
                              );
                            }
                            final category = filtered[
                                widget.isRootTab ? index : index - 1];
                            final open = query.isNotEmpty ||
                                expanded.contains(category.id);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _Reveal(
                                index: index,
                                  child: _CategoryCard(
                                  category: category,
                                  name: _name(category, langCode),
                                  term: query,
                                  expanded: open && category.children.isNotEmpty,
                                  onTap: () {
                                    if (category.children.isNotEmpty) {
                                      _toggleCategory(category.id);
                                    } else {
                                      _openCategory(category);
                                    }
                                  },
                                  onChildTap: _openCategory,
                                  childName: (child) => _name(child, langCode),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          if (widget.isFromDrawer) Gap(context.mediaQueryPadding.bottom),
        ],
      ),
    );
  }
}

class _CategoriesHeader extends StatelessWidget {
  const _CategoriesHeader({
    required this.glow,
    required this.showClose,
    required this.searchController,
    required this.searchFocus,
    required this.onQuery,
  });

  final Animation<double> glow;
  final bool showClose;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glow,
      builder: (context, child) {
        final drift = math.sin(glow.value * math.pi * 2);
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withAlpha(28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -36,
                right: -20 + (18 * drift),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primary.withAlpha(28),
                  ),
                ),
              ),
              Positioned(
                bottom: 48,
                left: -30 - (12 * drift),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primary2.withAlpha(180),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Categories'.tr, style: AppFont.font20W700Black),
                  ),
                  if (showClose)
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Get.back(),
                    ),
                ],
              ),
              const Gap(14),
              TextField(
                controller: searchController,
                focusNode: searchFocus,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => searchFocus.unfocus(),
                onChanged: onQuery,
                style: AppFont.font14W500Black,
                decoration: InputDecoration(
                  hintText: 'Search'.tr,
                  hintStyle: AppFont.font14W500Grey2,
                  prefixIcon: Icon(Icons.search, color: AppColor.grey2),
                  filled: true,
                  fillColor: AppColor.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColor.primary.withAlpha(28)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColor.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 8)) * 60;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.name,
    required this.term,
    required this.expanded,
    required this.onTap,
    required this.onChildTap,
    required this.childName,
  });

  final CategoryModel category;
  final String name;
  final String term;
  final bool expanded;
  final VoidCallback onTap;
  final ValueChanged<CategoryModel> onChildTap;
  final String Function(CategoryModel child) childName;

  @override
  Widget build(BuildContext context) {
    final hasChildren = category.children.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withAlpha(22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xffF0EBE4)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _CategoryAvatar(image: category.image, label: name, size: 58),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HighlightedName(
                            text: name,
                            term: term,
                            maxLines: 1,
                            style: AppFont.font16W700Black,
                          ),
                          if (hasChildren) ...[
                            const Gap(4),
                            Text(
                              '${category.children.length}',
                              style: AppFont.font12W600Primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        hasChildren
                            ? Icons.keyboard_arrow_down
                            : Icons.chevron_right,
                        size: hasChildren ? 22 : 18,
                        color: AppColor.grey2,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < category.children.length; i++)
                                Padding(
                                  padding: EdgeInsetsDirectional.only(
                                    end: i == category.children.length - 1
                                        ? 0
                                        : 10,
                                  ),
                                  child: _ChildTile(
                                    category: category.children[i],
                                    name: childName(category.children[i]),
                                    term: term,
                                    onTap: () =>
                                        onChildTap(category.children[i]),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  const _ChildTile({
    required this.category,
    required this.name,
    required this.term,
    required this.onTap,
  });

  final CategoryModel category;
  final String name;
  final String term;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      child: Material(
        color: AppColor.primary2,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _CategoryAvatar(image: category.image, label: name, size: 44),
                const Gap(8),
                _HighlightedName(
                  text: name,
                  term: term,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: AppFont.font10w400Black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightedName extends StatelessWidget {
  const _HighlightedName({
    required this.text,
    required this.term,
    required this.style,
    this.maxLines = 1,
    this.textAlign,
  });

  final String text;
  final String term;
  final TextStyle style;
  final int maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return SubstringHighlight(
      text: text,
      term: term,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign?? TextAlign.center,
      textStyle: style,
      textStyleHighlight: style.copyWith(
        color: AppColor.primary,
        fontWeight: FontWeight.w700,
        backgroundColor: const Color(0xffFFF3C4),
      ),
    );
  }
}

class _CategoryAvatar extends StatelessWidget {
  const _CategoryAvatar({
    required this.image,
    required this.label,
    required this.size,
  });

  final String? image;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final letter = label.trim().isEmpty ? '' : label.trim().characters.first;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: size,
        height: size,
        child: image != null && image!.isNotEmpty
            ? ImageOrSvg(image!, width: size, height: size, fit: BoxFit.cover)
            : ColoredBox(
                color: AppColor.primary.withAlpha(28),
                child: Center(
                  child: Text(
                    letter,
                    style: AppFont.font16W700Black.copyWith(
                      color: AppColor.primary,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _AllCategoriesTile extends StatelessWidget {
  const _AllCategoriesTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.primary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(36),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.layers, color: Colors.white),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  'All'.tr,
                  style: AppFont.font16W700Black.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCategories extends StatelessWidget {
  const _EmptyCategories({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColor.grey2),
            const Gap(16),
            Text(
              hasQuery ? 'No Results Found'.tr : 'No Categories'.tr,
              style: AppFont.font18W700Black,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesLoading extends StatelessWidget {
  const _CategoriesLoading({
    required this.bottomInset,
    required this.showAllTile,
  });

  final double bottomInset;
  final bool showAllTile;

  @override
  Widget build(BuildContext context) {
    final base = Color.lerp(AppColor.primary, Colors.white, 0.72)!;
    final highlight = Color.lerp(AppColor.primary, Colors.white, 0.9)!;
    final cards = List.generate(5, (index) => _placeholderCategory(index));
    return Skeletonizer(
      enabled: true,
      ignorePointers: true,
      containersColor: AppColor.primary.withAlpha(22),
      effect: ShimmerEffect(
        baseColor: base,
        highlightColor: highlight,
        duration: const Duration(milliseconds: 1200),
      ),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset),
        itemCount: cards.length + (showAllTile ? 1 : 0),
        itemBuilder: (context, index) {
          if (showAllTile && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AllCategoriesTile(onTap: () {}),
            );
          }
          final category = cards[showAllTile ? index - 1 : index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CategoryCard(
              category: category,
              name: category.name,
              term: '',
              expanded: false,
              onTap: () {},
              onChildTap: (_) {},
              childName: (child) => child.name,
            ),
          );
        },
      ),
    );
  }
}

CategoryModel _placeholderCategory(int index) {
  return CategoryModel(
    id: 'skeleton-$index',
    name: 'Category name',
    nameTr: 'Category name',
    nameAr: 'اسم التصنيف',
    slug: 'skeleton-$index',
    level: 0,
    order: 0,
    isActive: true,
    createdAt: '',
    updatedAt: '',
    v: 0,
    children: List.generate(
      4,
      (child) => CategoryModel(
        id: 'skeleton-$index-$child',
        name: 'Subcategory',
        nameTr: 'Subcategory',
        nameAr: 'تصنيف فرعي',
        slug: 'skeleton-$index-$child',
        level: 1,
        order: 0,
        isActive: true,
        createdAt: '',
        updatedAt: '',
        v: 0,
      ),
    ),
  );
}
