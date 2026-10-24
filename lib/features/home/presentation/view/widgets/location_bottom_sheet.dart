import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/location_service/location_service.dart';
import 'package:heraj_meem/features/home/data/models/baho_feed.dart';
import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/location/data/models/city_model.dart';
import 'package:heraj_meem/ui/shared_widgets/loading_widget.dart';
import 'package:heraj_meem/ui/ui.dart';

final selectedCityProvider = StateProvider.autoDispose<CityModel?>((ref) => null);

final currentDisplayLocationProvider = StateProvider<LocationDetails?>((ref) => null);

Future<void> showLocationBottomSheet({BuildContext? context}) async {
  await showModalBottomSheet<void>(
    context: Get.context ?? context!,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RegionCitySheet(),
  );
}

class _RegionCitySheet extends ConsumerStatefulWidget {
  const _RegionCitySheet();

  @override
  ConsumerState<_RegionCitySheet> createState() => _RegionCitySheetState();
}

class _RegionCitySheetState extends ConsumerState<_RegionCitySheet> {
  BahoRegion? _region;
  BahoCity? _city;
  bool _saving = false;

  Future<void> _save() async {
    final region = _region;
    final city = _city;
    if (region == null || city == null) return;
    final place = BahoPlace(
      regionId: region.id,
      regionName: region.nameAr,
      cityId: city.id,
      cityName: city.nameAr,
      citySlug: city.slug,
    );
    setState(() => _saving = true);
    try {
      await saveUserPlace(place);
    } catch (error) {
      if (mounted) {
        UIHelper.showGlobalSnackBar(
          text: error.toString(),
          color: AppColor.danger,
        );
      }
    }
    if (!mounted) return;
    ref.read(bahoPlaceProvider.notifier).state = place;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final regionsAsync = ref.watch(bahoRegionsProvider);
    final districtsAsync = _city == null
        ? null
        : ref.watch(bahoDistrictsProvider(_city!.id));

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                if (_region != null)
                  IconButton(
                    onPressed: () => setState(() {
                      if (_city != null) {
                        _city = null;
                      } else {
                        _region = null;
                      }
                    }),
                    icon: const Icon(Icons.arrow_back),
                  ),
                Expanded(
                  child: Text(
                    _city?.nameAr ?? _region?.nameAr ?? 'All regions'.tr,
                    style: AppFont.font18W700Black,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          if (_region == null)
            ListTile(
              title: Text('All regions'.tr, style: AppFont.font14W600Black),
              onTap: () async {
                try {
                  await clearUserPlace();
                } catch (_) {}
                ref.read(bahoPlaceProvider.notifier).state = null;
                if (context.mounted) Navigator.pop(context);
              },
            ),
          Expanded(
            child: regionsAsync.when(
              loading: () => const LoadingWidget(),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (regions) {
                if (_region == null) {
                  return ListView.builder(
                    itemCount: regions.length,
                    itemBuilder: (context, index) {
                      final region = regions[index];
                      return ListTile(
                        title: Text(region.nameAr, style: AppFont.font14W600Black),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => setState(() => _region = region),
                      );
                    },
                  );
                }
                final citiesAsync = ref.watch(bahoCitiesProvider(_region!.id));
                return citiesAsync.when(
                  loading: () => const LoadingWidget(),
                  error: (error, _) => Center(child: Text(error.toString())),
                  data: (cities) {
                    final shown = cities.isEmpty ? _region!.cities : cities;
                    if (_city == null) {
                      return ListView.builder(
                        itemCount: shown.length,
                        itemBuilder: (context, index) {
                          final city = shown[index];
                          return ListTile(
                            title: Text(city.nameAr, style: AppFont.font14W600Black),
                            onTap: () => setState(() => _city = city),
                          );
                        },
                      );
                    }
                    return Column(
                      children: [
                        Expanded(
                          child: districtsAsync == null
                              ? const SizedBox.shrink()
                              : districtsAsync.when(
                                  loading: () => const LoadingWidget(),
                                  error: (error, _) =>
                                      Center(child: Text(error.toString())),
                                  data: (districts) {
                                    if (districts.isEmpty) {
                                      return Center(
                                        child: Text(
                                          cityEmptyLabel(_city!),
                                          style: AppFont.font14W500Grey2,
                                        ),
                                      );
                                    }
                                    return ListView.builder(
                                      itemCount: districts.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(
                                            districts[index].nameAr,
                                            style: AppFont.font14W500Black,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: _saving ? null : _save,
                              child: Text(_saving ? '...' : 'Save'.tr),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const Gap(8),
        ],
      ),
    );
  }

  String cityEmptyLabel(BahoCity city) => city.nameAr;
}
