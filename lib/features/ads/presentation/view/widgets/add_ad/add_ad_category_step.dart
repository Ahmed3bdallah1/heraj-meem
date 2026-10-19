part of '../../add_ad_screen.dart';

class _AddAdCategoryStep extends ConsumerWidget {
  const _AddAdCategoryStep({
    required this.selectedCategory,
    required this.trail,
  });

  final ValueNotifier<BahoCategory?> selectedCategory;
  final ValueNotifier<List<BahoCategory>> trail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(bahoCategoriesProvider);
    final language = Get.locale?.languageCode ?? 'ar';
    return categories.customWhen(
      ref: ref,
      refreshable: bahoCategoriesProvider.future,
      data: (items) {
        return ValueListenableBuilder<List<BahoCategory>>(
          valueListenable: trail,
          builder: (context, path, _) {
            final current = path.isEmpty ? items : path.last.children;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (path.isNotEmpty)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () =>
                          trail.value = path.sublist(0, path.length - 1),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(
                        path.last.nameFor(language),
                        style: AppFont.font14W600Primary,
                      ),
                    ),
                  ),
                ValueListenableBuilder<BahoCategory?>(
                  valueListenable: selectedCategory,
                  builder: (context, selected, _) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: current.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final category = current[index];
                        return _AddAdCategoryTile(
                          category: category,
                          language: language,
                          selected: selected?.id == category.id,
                          onTap: () {
                            if (category.children.isNotEmpty) {
                              trail.value = [...path, category];
                              return;
                            }
                            selectedCategory.value = category;
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
