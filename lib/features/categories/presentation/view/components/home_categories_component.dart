import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/categories/presentation/view/category_screen.dart';
import 'package:heraj_meem/features/home/data/models/baho_feed.dart';
import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/home/presentation/view/widgets/home_entrance.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeCategoriesComponent extends ConsumerWidget {
  const HomeCategoriesComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(bahoCategoriesProvider);
    final language = Get.locale?.languageCode ?? 'ar';
    return categories.when(
      loading: () => const _CategoryTreesSkeleton(),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(error.toString(), style: AppFont.font12W600Primary),
      ),
      data: (items) {
        final ranked = [...items]
          ..sort((a, b) => b.children.length.compareTo(a.children.length));
        final top = ranked.take(2).toList();
        return Column(
          children: [
            for (var i = 0; i < top.length; i++)
              HomeEntrance(
                index: i + 2,
                child: _CategoryTreeCard(
                  category: top[i],
                  language: language,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryTreeCard extends StatelessWidget {
  const _CategoryTreeCard({
    required this.category,
    required this.language,
  });

  final BahoCategory category;
  final String language;

  @override
  Widget build(BuildContext context) {
    final tiles = category.gridChildren;
    final image = bahoMediaUrl(category.imageUrl);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffECEEF2)),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(22),
                bottom: Radius.circular(tiles.isEmpty ? 22 : 0),
              ),
              onTap: () => Get.to(
                () => CategoryScreen(category: category.toCategoryModel()),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(20),
                    bottom: Radius.circular(tiles.isEmpty ? 20 : 0),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: image.isNotEmpty
                            ? Image.network(
                                image,
                                width: 42,
                                height: 42,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const _CategoryImageFallback(),
                              )
                            : const _CategoryImageFallback(),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          category.nameFor(language),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: AppFont.font16W700Black,
                        ),
                      ),
                      Icon(
                        Icons.chevron_left,
                        color: AppColor.grey2,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (tiles.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
              itemCount: tiles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final child = tiles[index];
                final childImage = bahoMediaUrl(child.imageUrl);
                return GestureDetector(
                  onTap: () => Get.to(
                    () => CategoryScreen(category: child.toCategoryModel()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xffF5F6F8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: childImage.isEmpty
                        ? Center(
                            child: Text(
                              child.nameFor(language),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: AppFont.font10w400Black,
                            ),
                          )
                        : Image.network(
                            childImage,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                child.nameFor(language),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: AppFont.font10w400Black,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryImageFallback extends StatelessWidget {
  const _CategoryImageFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColor.primary.withAlpha(30),
      child: SizedBox(
        width: 42,
        height: 42,
        child: Icon(Icons.image_outlined, color: AppColor.primary, size: 20),
      ),
    );
  }
}

class _CategoryTreesSkeleton extends StatelessWidget {
  const _CategoryTreesSkeleton();

  @override
  Widget build(BuildContext context) {
    final language = Get.locale?.languageCode ?? 'ar';
    final base = Color.lerp(AppColor.primary, Colors.white, 0.72)!;
    final highlight = Color.lerp(AppColor.primary, Colors.white, 0.9)!;
    return Skeletonizer(
      enabled: true,
      ignorePointers: true,
      containersColor: AppColor.primary.withAlpha(22),
      effect: ShimmerEffect(
        baseColor: base,
        highlightColor: highlight,
        duration: const Duration(milliseconds: 1200),
      ),
      child: Column(
        children: [
          for (var i = 0; i < 2; i++)
            _CategoryTreeCard(
              category: _placeholderCategory,
              language: language,
            ),
        ],
      ),
    );
  }
}

const _placeholderCategory = BahoCategory(
  id: 'skeleton',
  slug: 'skeleton',
  nameAr: 'التصنيف',
  nameEn: 'Category',
  children: [
    BahoCategory(id: 'c1', slug: 'c1', nameAr: 'فرعي', nameEn: 'Child'),
    BahoCategory(id: 'c2', slug: 'c2', nameAr: 'فرعي', nameEn: 'Child'),
    BahoCategory(id: 'c3', slug: 'c3', nameAr: 'فرعي', nameEn: 'Child'),
    BahoCategory(id: 'c4', slug: 'c4', nameAr: 'فرعي', nameEn: 'Child'),
  ],
);
