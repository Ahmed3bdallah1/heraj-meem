import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../config/app_font.dart';
import '../../../../location/data/models/city_model.dart';
import '../../../../location/data/models/district_model.dart';
import '../../../../location/domain/use_case/fetch_neighborhoods_use_case.dart';
import '../../../../location/presentation/managers/location_provider.dart';

class SelectCityStep extends ConsumerStatefulWidget {
  final CityModel? selectedCity;
  final DistrictModel? selectedDistrict;
  final NeighborhoodModel? selectedNeighborhood;
  final ValueChanged<CityModel> onCitySelected;
  final ValueChanged<DistrictModel?> onDistrictSelected;
  final ValueChanged<NeighborhoodModel?> onNeighborhoodSelected;

  const SelectCityStep({super.key,
    required this.selectedCity,
    required this.selectedDistrict,
    required this.selectedNeighborhood,
    required this.onCitySelected,
    required this.onDistrictSelected,
    required this.onNeighborhoodSelected,
  });

  @override
  ConsumerState<SelectCityStep> createState() => SelectCityStepState();
}

class SelectCityStepState extends ConsumerState<SelectCityStep>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  List<CityModel> _filteredCities = [];
  bool _forceShowCitySelector = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query, List<CityModel> allCities) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = allCities;
      } else {
        final queryLower = query.toLowerCase();
        _filteredCities = allCities.where((city) {
          final currentLocale = Get.locale?.languageCode ?? 'en';
          final cityName = city.getLocalizedName(currentLocale).toLowerCase();
          return cityName.contains(queryLower) ||
              city.name.toLowerCase().contains(queryLower) ||
              city.nameTr.toLowerCase().contains(queryLower) ||
              city.nameAr.toLowerCase().contains(queryLower);
        }).toList();
      }
    });
  }

  String _getCityDisplayName(CityModel city) {
    final currentLocale = Get.locale?.languageCode ?? 'en';
    return city.getLocalizedName(currentLocale);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final citiesAsync = ref.watch(fetchCitiesProvider);
    final langCode = Get.locale?.languageCode ?? 'en';
    final showCitySelector =
        widget.selectedCity == null || _forceShowCitySelector;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCitySelector) ...[
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (query) {
                citiesAsync.whenData((citiesResponse) {
                  _filterCities(query, citiesResponse.cities);
                });
              },
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
              child: citiesAsync.when(
                data: (citiesResponse) {
                  if (_filteredCities.isEmpty) {
                    _filteredCities = citiesResponse.cities;
                  }
                  return ListView.builder(
                    itemCount: _filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = _filteredCities[index];
                      final isSelected = widget.selectedCity?.code == city.code;
                      return ListTile(
                        title: Text(
                          _getCityDisplayName(city),
                          style: AppFont.font14W600Black,
                        ),
                        trailing: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColor.primary
                                  : AppColor.grey1,
                              width: 2,
                            ),
                            color: isSelected
                                ? AppColor.primary
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                              : null,
                        ),
                        onTap: () {
                          widget.onCitySelected(city);
                          setState(() {
                            _forceShowCitySelector = false;
                          });
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Text('Error loading cities'.tr),
                ),
              ),
            ),
            const Gap(16),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColor.primary2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_city, color: AppColor.primary, size: 18),
                  const Gap(8),
                  Text(
                    _getCityDisplayName(widget.selectedCity!),
                    style: AppFont.font14W600Black,
                  ),
                  const Gap(12),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _forceShowCitySelector = true;
                      });
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text('Edit'.tr),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColor.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),
          ],
          _DistrictDropdown(
            enabled: widget.selectedCity != null,
            cityCode: widget.selectedCity?.code,
            selectedDistrict: widget.selectedDistrict,
            onSelected: (district) {
              widget.onDistrictSelected(district);
            },
            langCode: langCode,
          ),
          const Gap(12),
          _NeighborhoodDropdown(
            enabled:
            widget.selectedCity != null && widget.selectedDistrict != null,
            cityCode: widget.selectedCity?.code,
            districtName: widget.selectedDistrict?.name,
            selectedNeighborhood: widget.selectedNeighborhood,
            onSelected: widget.onNeighborhoodSelected,
            langCode: langCode,
          ),
        ],
      ),
    );
  }
}


class _DistrictDropdown extends ConsumerWidget {
  final bool enabled;
  final String? cityCode;
  final DistrictModel? selectedDistrict;
  final ValueChanged<DistrictModel?> onSelected;
  final String langCode;

  const _DistrictDropdown({
    required this.enabled,
    required this.cityCode,
    required this.selectedDistrict,
    required this.onSelected,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled || cityCode == null) {
      return DropdownButtonFormField<DistrictModel>(
        initialValue: null,
        items: const [],
        onChanged: null,
        decoration: InputDecoration(
          labelText: 'Select District'.tr,
          filled: true,
          fillColor: AppColor.primary2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );
    }

    final districtsAsync = ref.watch(fetchDistrictsProvider(cityCode!));

    return districtsAsync.when(
      data: (response) {
        final items = response.districts;
        return DropdownButtonFormField<DistrictModel>(
          initialValue: selectedDistrict,
          items: items
              .map(
                (d) => DropdownMenuItem(
              value: d,
              child: Text(d.getLocalizedName(langCode)),
            ),
          )
              .toList(),
          onChanged: onSelected,
          decoration: InputDecoration(
            labelText: 'Select District'.tr,
            filled: true,
            fillColor: AppColor.primary2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Error loading districts'.tr),
    );
  }
}

class _NeighborhoodDropdown extends ConsumerWidget {
  final bool enabled;
  final String? cityCode;
  final String? districtName;
  final NeighborhoodModel? selectedNeighborhood;
  final ValueChanged<NeighborhoodModel?> onSelected;
  final String langCode;

  const _NeighborhoodDropdown({
    required this.enabled,
    required this.cityCode,
    required this.districtName,
    required this.selectedNeighborhood,
    required this.onSelected,
    required this.langCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled || cityCode == null || districtName == null) {
      return DropdownButtonFormField<NeighborhoodModel>(
        initialValue: null,
        items: const [],
        onChanged: null,
        decoration: InputDecoration(
          labelText: 'Select Neighborhood'.tr,
          filled: true,
          fillColor: AppColor.primary2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );
    }

    final params = FetchNeighborhoodsParams(
      cityCode: cityCode!,
      districtName: districtName!,
    );
    final neighborhoodsAsync = ref.watch(fetchNeighborhoodsProvider(params));

    return neighborhoodsAsync.when(
      data: (response) {
        final items = response.neighborhoods;
        return DropdownButtonFormField<NeighborhoodModel>(
          initialValue: selectedNeighborhood,
          items: items
              .map(
                (n) => DropdownMenuItem(
              value: n,
              child: Text(n.getLocalizedName(langCode)),
            ),
          )
              .toList(),
          onChanged: onSelected,
          decoration: InputDecoration(
            labelText: 'Select Neighborhood'.tr,
            filled: true,
            fillColor: AppColor.primary2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Error loading neighborhoods'.tr),
    );
  }
}