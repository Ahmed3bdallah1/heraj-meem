part of '../../add_ad_screen.dart';

class _AddAdCityStep extends ConsumerStatefulWidget {
  const _AddAdCityStep({required this.selectedCity});

  final ValueNotifier<BahoCity?> selectedCity;

  @override
  ConsumerState<_AddAdCityStep> createState() => _AddAdCityStepState();
}

class _AddAdCityStepState extends ConsumerState<_AddAdCityStep> {
  final searchController = TextEditingController();
  final searchFocus = FocusNode();
  final query = ValueNotifier('');
  final region = ValueNotifier<BahoRegion?>(null);

  @override
  void dispose() {
    searchController.dispose();
    searchFocus.dispose();
    query.dispose();
    region.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final regions = ref.watch(bahoRegionsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            focusNode: searchFocus,
            textInputAction: TextInputAction.done,
            onChanged: (value) => query.value = value.trim().toLowerCase(),
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
          Expanded(
            child: regions.customWhen(
              ref: ref,
              refreshable: bahoRegionsProvider.future,
              data: (items) {
                return ValueListenableBuilder<BahoRegion?>(
                  valueListenable: region,
                  builder: (context, currentRegion, _) {
                    return ValueListenableBuilder<String>(
                      valueListenable: query,
                      builder: (context, term, _) {
                        if (currentRegion == null) {
                          final shown = items.where((item) {
                            if (term.isEmpty) return true;
                            return item.nameAr.toLowerCase().contains(term) ||
                                item.nameEn.toLowerCase().contains(term);
                          }).toList();
                          return ListView.builder(
                            itemCount: shown.length,
                            itemBuilder: (context, index) {
                              final item = shown[index];
                              return ListTile(
                                title: Text(
                                  _name(item.nameAr, item.nameEn),
                                  style: AppFont.font14W600Black,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => region.value = item,
                              );
                            },
                          );
                        }
                        final loaded =
                            ref.watch(bahoCitiesProvider(currentRegion.id));
                        final source =
                            loaded.valueOrNull ?? currentRegion.cities;
                        final cities = source.where((item) {
                          if (term.isEmpty) return true;
                          return item.nameAr.toLowerCase().contains(term) ||
                              item.nameEn.toLowerCase().contains(term);
                        }).toList();
                        return Column(
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton.icon(
                                onPressed: () => region.value = null,
                                icon: const Icon(Icons.arrow_back),
                                label: Text(
                                  _name(
                                    currentRegion.nameAr,
                                    currentRegion.nameEn,
                                  ),
                                  style: AppFont.font14W600Primary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: loaded.isLoading && source.isEmpty
                                  ? const LoadingWidget()
                                  : ValueListenableBuilder<BahoCity?>(
                                      valueListenable: widget.selectedCity,
                                      builder: (context, selected, _) {
                                        return ListView.builder(
                                          itemCount: cities.length,
                                          itemBuilder: (context, index) {
                                            final city = cities[index];
                                            final isSelected =
                                                selected?.id == city.id;
                                            return ListTile(
                                              title: Text(
                                                _name(city.nameAr, city.nameEn),
                                                style: AppFont.font14W600Black,
                                              ),
                                              trailing: _AddAdCheckMark(
                                                selected: isSelected,
                                              ),
                                              onTap: () => widget
                                                  .selectedCity.value = city,
                                            );
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _name(String arabic, String english) {
    final language = Get.locale?.languageCode ?? 'ar';
    if (language == 'ar') return arabic.isEmpty ? english : arabic;
    return english.isEmpty ? arabic : english;
  }
}
