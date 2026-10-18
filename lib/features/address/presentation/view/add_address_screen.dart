import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/loading_provider.dart';
import 'package:heraj_meem/core/service/localization_service/localization_service.dart';
import 'package:heraj_meem/features/location/data/models/city_model.dart';
import 'package:heraj_meem/features/location/data/models/district_model.dart';
import 'package:heraj_meem/features/location/domain/use_case/fetch_neighborhoods_use_case.dart';
import 'package:heraj_meem/features/location/presentation/managers/location_provider.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_reactive_form_consumer.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_text_field.dart';
import 'widgets/animated_background.dart';
import 'package:heraj_meem/ui/ui.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tuple/tuple.dart';
import '../../data/enum/country_enum.dart';
import '../../data/model/address_model.dart';
import '../../domain/use_case/address_use_cases.dart';
import '../manager/address_provider.dart';
import 'map_selector_screen.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key, this.address});

  final AddressModel? address;

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen>
    with TickerProviderStateMixin {
  late final FormGroup formGroup;
  late final bool isEditing;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  static const List<double> cairoCoordinates = [31.2357, 30.0444];
  static const LatLng cairoLatLng = LatLng(30.0444, 31.2357);

  CityModel? _selectedCity;
  DistrictModel? _selectedDistrict;
  NeighborhoodModel? _selectedNeighborhood;
  final TextEditingController _citySearchController = TextEditingController();
  List<CityModel> _filteredCities = [];
  late AnimationController _backgroundAnimationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    isEditing = widget.address != null;
    formGroup = FormGroup({
      'label': FormControl(
        validators: [Validators.required],
        value: widget.address?.label ?? 'Home'.tr,
      ),
      'fullName': FormControl(
        validators: [Validators.required],
        value: widget.address?.fullName ?? widget.address?.name,
      ),
      'phone': FormControl(
        validators: [Validators.required],
        value: widget.address?.phone,
      ),
      'addressLine1': FormControl(
        validators: [Validators.required],
        value: widget.address?.addressLine1 ?? widget.address?.address,
      ),
      'addressLine2': FormControl(
        value: widget.address?.addressLine2,
      ),
      'city': FormControl<String>(
        value: widget.address?.city,
      ),
      'country': FormControl<String>(
        value: widget.address?.country ?? CountryEnum.defaultCountry.value,
      ),
      'state': FormControl<String>(
        value: widget.address?.state,
      ),
      'postalCode': FormControl<String>(
        value: widget.address?.postalCode,
      ),
      'isDefault': FormControl<bool>(
        value: widget.address?.isDefault ?? false,
      ),
      'coordinates': FormControl<List<double>>(
        value: widget.address?.location?.coordinates ?? cairoCoordinates,
      ),
    });
    _citySearchController.addListener(_onCitySearchChanged);
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkerFromCoordinates();
      _initializeLocationData();
    });
  }

  void _initializeLocationData() async {
    // Try to find and set the city from the address
    if (widget.address?.city != null) {
      final citiesAsync = ref.read(fetchCitiesProvider);
      citiesAsync.whenData((citiesResponse) {
        final matchingCity = citiesResponse.cities.firstWhere(
          (city) =>
              city.name == widget.address?.city ||
              city.nameAr == widget.address?.city ||
              city.nameTr == widget.address?.city,
          orElse: () => citiesResponse.cities.first,
        );
        setState(() {
          _selectedCity = matchingCity;
          _filteredCities = citiesResponse.cities;
        });
        formGroup.control('city').value = matchingCity.getLocalizedName(
          getIt<LocaleService>().getLocale().locale.languageCode,
        );
      });
    }
  }

  void _onCitySearchChanged() {
    final query = _citySearchController.text.toLowerCase();
    final citiesAsync = ref.read(fetchCitiesProvider);
    citiesAsync.whenData((citiesResponse) {
      setState(() {
        if (query.isEmpty) {
          _filteredCities = citiesResponse.cities;
        } else {
          final langCode =
              getIt<LocaleService>().getLocale().locale.languageCode;
          _filteredCities = citiesResponse.cities.where((city) {
            final cityName = city.getLocalizedName(langCode).toLowerCase();
            return cityName.contains(query) ||
                city.name.toLowerCase().contains(query) ||
                city.nameAr.toLowerCase().contains(query) ||
                city.nameTr.toLowerCase().contains(query);
          }).toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _citySearchController.dispose();
    _backgroundAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _updateMarkerFromCoordinates();
  }

  void _updateMarkerFromCoordinates() {
    final coordinates = formGroup.control('coordinates').value as List<double>?;
    if (coordinates != null && coordinates.length >= 2) {
      final latLng = LatLng(coordinates[1], coordinates[0]);
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('selected_location'),
            position: latLng,
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 14.0),
      );
    }
  }

  LatLng _getInitialPosition() {
    final coordinates = formGroup.control('coordinates').value as List<double>?;
    if (coordinates != null && coordinates.length >= 2) {
      return LatLng(coordinates[1], coordinates[0]);
    }
    return cairoLatLng;
  }

  Future<void> _openMapSelector() async {
    final currentCoordinates =
        formGroup.control('coordinates').value as List<double>? ??
            widget.address?.location?.coordinates ??
            cairoCoordinates;
    print(currentCoordinates);
    final result = await Get.to<List<double>>(
      () => MapSelectorScreen(
        initialCoordinates: currentCoordinates,
      ),
    );

    if (result != null) {
      formGroup.control('coordinates').value = result;
      _updateMarkerFromCoordinates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AddressAnimatedBackground(
            animation: _backgroundAnimationController,
          ),
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Animated AppBar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColor.black,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    isEditing ? "Edit Address".tr : "Add Address".tr,
                    style: AppFont.font20W700Black,
                  ),
                  centerTitle: false,
                ),
              ),
              // Form Content
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ReactiveForm(
                    formGroup: formGroup,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Personal Information Card
                        _FormSectionCard(
                          title: "Personal Information".tr,
                          icon: Icons.person_outline_rounded,
                          children: [
                            CustomTextField(
                              formControlName: 'label',
                              hintText: "Label (e.g., Home, Work)".tr,
                              labelText: "Label".tr,
                            ),
                            const Gap(16),
                            CustomTextField(
                              formControlName: 'fullName',
                              hintText: "Full Name".tr,
                              labelText: "Full Name".tr,
                            ),
                            const Gap(16),
                            CustomTextField(
                              formControlName: 'phone',
                              hintText: "Phone number".tr,
                              labelText: "Phone number".tr,
                            ),
                          ],
                        ),
                        const Gap(16),
                        // Address Information Card
                        _FormSectionCard(
                          title: "Address Details".tr,
                          icon: Icons.location_on_outlined,
                          children: [
                            CustomTextField(
                              formControlName: 'addressLine1',
                              hintText: "Address Line 1".tr,
                              labelText: "Address Line 1".tr,
                              maxLines: 2,
                            ),
                            const Gap(16),
                            CustomTextField(
                              formControlName: 'addressLine2',
                              hintText: "Address Line 2 (Optional)".tr,
                              labelText: "Address Line 2".tr,
                              maxLines: 2,
                            ),
                          ],
                        ),
                        const Gap(16),
                        // Location Selection Card
                        _FormSectionCard(
                          title: "Location".tr,
                          icon: Icons.map_outlined,
                          children: [
                            // City Selection
                            _CitySelector(
                              selectedCity: _selectedCity,
                              searchController: _citySearchController,
                              filteredCities: _filteredCities,
                              onCitySelected: (city) {
                                setState(() {
                                  _selectedCity = city;
                                  _selectedDistrict = null;
                                  _selectedNeighborhood = null;
                                  final langCode = getIt<LocaleService>()
                                      .getLocale()
                                      .locale
                                      .languageCode;
                                  formGroup.control('city').value =
                                      city.getLocalizedName(langCode);
                                  formGroup.control('state').value = null;
                                });
                              },
                            ),
                            const Gap(16),
                            // District Selection
                            _DistrictSelector(
                              enabled: _selectedCity != null,
                              cityCode: _selectedCity?.code,
                              selectedDistrict: _selectedDistrict,
                              onDistrictSelected: (district) {
                                setState(() {
                                  _selectedDistrict = district;
                                  _selectedNeighborhood = null;
                                  if (district != null) {
                                    final langCode = getIt<LocaleService>()
                                        .getLocale()
                                        .locale
                                        .languageCode;
                                    formGroup.control('state').value =
                                        district.getLocalizedName(langCode);
                                  } else {
                                    formGroup.control('state').value = null;
                                  }
                                });
                              },
                            ),
                            const Gap(16),
                            // Neighborhood Selection
                            _NeighborhoodSelector(
                              enabled: _selectedCity != null &&
                                  _selectedDistrict != null,
                              cityCode: _selectedCity?.code,
                              districtName: _selectedDistrict?.name,
                              selectedNeighborhood: _selectedNeighborhood,
                              onNeighborhoodSelected: (neighborhood) {
                                setState(() {
                                  _selectedNeighborhood = neighborhood;
                                });
                              },
                            ),
                            const Gap(16),
                            // Country Field
                            CustomTextField<String>(
                              formControlName: 'country',
                              hintText: "Country".tr,
                              labelText: "Country".tr,
                              type: TextFieldType.selectable,
                              items: CountryEnum.allCountries
                                  .map((country) => DropdownMenuItem<String>(
                                        value: country.value,
                                        child: Text(country.displayName),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                        const Gap(16),
                        // Map Selection Card
                        _FormSectionCard(
                          title: "Map Location".tr,
                          icon: Icons.map_rounded,
                          children: [
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColor.primary.withAlpha(50),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.primary.withAlpha(20),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    GoogleMap(
                                      onMapCreated: _onMapCreated,
                                      initialCameraPosition: CameraPosition(
                                        target: _getInitialPosition(),
                                        zoom: 14.0,
                                      ),
                                      markers: _markers,
                                      myLocationButtonEnabled: false,
                                      zoomControlsEnabled: false,
                                      mapType: MapType.normal,
                                      zoomGesturesEnabled: false,
                                      scrollGesturesEnabled: false,
                                      tiltGesturesEnabled: false,
                                      rotateGesturesEnabled: false,
                                    ),
                                    // Overlay with button
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.1),
                                            Colors.black.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: ElevatedButton.icon(
                                          onPressed: _openMapSelector,
                                          icon: const Icon(Icons.map_rounded),
                                          label: Text("Select Location".tr),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 14,
                                            ),
                                            backgroundColor: AppColor.white,
                                            foregroundColor: AppColor.primary,
                                            elevation: 8,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        // Default Address Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primary.withAlpha(20),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ReactiveValueListenableBuilder<bool>(
                            formControlName: 'isDefault',
                            builder: (context, control, child) {
                              return Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColor.primary.withAlpha(25),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.star_rounded,
                                      color: AppColor.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const Gap(16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Set as default address".tr,
                                          style: AppFont.font16W600Black,
                                        ),
                                        const Gap(4),
                                        Text(
                                          "Use this address for quick checkout"
                                              .tr,
                                          style: AppFont.font12W400Grey1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: control.value ?? false,
                                    onChanged: control.enabled
                                        ? (value) {
                                            control.value = value;
                                          }
                                        : null,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Gap(MediaQuery.of(context).padding.bottom + 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Floating Save Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(0),
                    Colors.white,
                    Colors.white,
                  ],
                ),
              ),
              child: CustomReactiveFormValidationConsumer(
                formGroup: formGroup,
                builder: (BuildContext context, FormGroup form, Widget? child) {
                  return Consumer(
                    builder: (BuildContext context, ref, Widget? child) {
                      final isLoading = ref.watch(isLoadingProvider(
                          isEditing ? "updateAddress" : "addAddress"));
                      return CustomFilledButton(
                        isLoading: isLoading,
                        isValid: form.valid,
                        height: 52,
                        onPressed: () async {
                          if (form.valid) {
                            try {
                              ref
                                  .read(isLoadingProvider(isEditing
                                          ? "updateAddress"
                                          : "addAddress")
                                      .notifier)
                                  .state = true;
                              final data = {
                                'label': form.control('label').value,
                                'fullName': form.control('fullName').value,
                                'phone': form.control('phone').value,
                                'addressLine1':
                                    form.control('addressLine1').value,
                                if (form.control('addressLine2').value !=
                                        null &&
                                    form
                                        .control('addressLine2')
                                        .value
                                        .toString()
                                        .isNotEmpty)
                                  'addressLine2':
                                      form.control('addressLine2').value,
                                if (form.control('city').value != null &&
                                    form
                                        .control('city')
                                        .value
                                        .toString()
                                        .isNotEmpty)
                                  'city': form.control('city').value,
                                if (form.control('country').value != null &&
                                    form
                                        .control('country')
                                        .value
                                        .toString()
                                        .isNotEmpty)
                                  'country': form.control('country').value,
                                if (form.control('state').value != null &&
                                    form
                                        .control('state')
                                        .value
                                        .toString()
                                        .isNotEmpty)
                                  'state': form.control('state').value,
                                if (form.control('postalCode').value != null &&
                                    form
                                        .control('postalCode')
                                        .value
                                        .toString()
                                        .isNotEmpty)
                                  'postalCode':
                                      form.control('postalCode').value,
                                'isDefault':
                                    form.control('isDefault').value ?? false,
                                if (form.control('coordinates').value != null)
                                  'coordinates':
                                      form.control('coordinates').value,
                              };

                              final res = isEditing
                                  ? await getIt<UpdateAddressUseCase>().call(
                                      Tuple2(widget.address!.id, data),
                                    )
                                  : await getIt<AddAddressUseCase>().call(data);

                              res.fold(
                                (l) {
                                  UIHelper.showAlert(l.message,
                                      type: DialogType.error);
                                },
                                (r) async {
                                  await UIHelper.showAlert(
                                    isEditing
                                        ? "Address updated successfully".tr
                                        : "Address added successfully".tr,
                                  );
                                  Get.back(result: true);
                                  ref.invalidate(fetchAddressesProvider);
                                },
                              );
                            } finally {
                              ref
                                  .read(isLoadingProvider(isEditing
                                          ? "updateAddress"
                                          : "addAddress")
                                      .notifier)
                                  .state = false;
                            }
                          } else {
                            form.markAllAsTouched();
                          }
                        },
                        text: "Save".tr,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Form Section Card Widget
class _FormSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _FormSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColor.primary, size: 24),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  title,
                  style: AppFont.font18W700Black,
                ),
              ),
            ],
          ),
          const Gap(20),
          ...children,
        ],
      ),
    );
  }
}

// City Selector Widget
class _CitySelector extends ConsumerWidget {
  final CityModel? selectedCity;
  final TextEditingController searchController;
  final List<CityModel> filteredCities;
  final ValueChanged<CityModel> onCitySelected;

  const _CitySelector({
    required this.selectedCity,
    required this.searchController,
    required this.filteredCities,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    final citiesAsync = ref.watch(fetchCitiesProvider);

    return citiesAsync.when(
      data: (citiesResponse) {
        final cities =
            filteredCities.isEmpty ? citiesResponse.cities : filteredCities;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "City".tr,
              style: AppFont.font14W600Black,
            ),
            const Gap(8),
            if (selectedCity == null)
              Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search City'.tr,
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColor.primary2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.grey1),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return ListTile(
                          title: Text(city.getLocalizedName(langCode)),
                          onTap: () {
                            onCitySelected(city);
                            searchController.clear();
                          },
                        );
                      },
                    ),
                  ),
                ],
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColor.primary2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_city,
                        color: AppColor.primary, size: 20),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        selectedCity!.getLocalizedName(langCode),
                        style: AppFont.font14W600Black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onCitySelected(citiesResponse.cities.first);
                        searchController.clear();
                      },
                      child: Text('Change'.tr),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Error loading cities'.tr),
    );
  }
}

// District Selector Widget
class _DistrictSelector extends ConsumerWidget {
  final bool enabled;
  final String? cityCode;
  final DistrictModel? selectedDistrict;
  final ValueChanged<DistrictModel?> onDistrictSelected;

  const _DistrictSelector({
    required this.enabled,
    required this.cityCode,
    required this.selectedDistrict,
    required this.onDistrictSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;

    if (!enabled || cityCode == null) {
      return CustomTextField<String>(
        formControlName: 'state',
        hintText: "District".tr,
        labelText: "District".tr,
        ignore: true,
      );
    }

    final districtsAsync = ref.watch(fetchDistrictsProvider(cityCode!));

    return districtsAsync.when(
      data: (response) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReactiveDropdownField<String>(
              formControlName: 'state',
              decoration: InputDecoration(
                labelText: "District".tr,
                hintText: "Select District".tr,
                filled: true,
                fillColor: AppColor.primary2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: response.districts
                  .map((d) => DropdownMenuItem<String>(
                        value: d.getLocalizedName(langCode),
                        child: Text(d.getLocalizedName(langCode)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  final district = response.districts.firstWhere(
                    (d) => d.getLocalizedName(langCode) == value,
                    orElse: () => response.districts.first,
                  );
                  onDistrictSelected(district);
                }
              },
            ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Error loading districts'.tr),
    );
  }
}

// Neighborhood Selector Widget
class _NeighborhoodSelector extends ConsumerWidget {
  final bool enabled;
  final String? cityCode;
  final String? districtName;
  final NeighborhoodModel? selectedNeighborhood;
  final ValueChanged<NeighborhoodModel?> onNeighborhoodSelected;

  const _NeighborhoodSelector({
    required this.enabled,
    required this.cityCode,
    required this.districtName,
    required this.selectedNeighborhood,
    required this.onNeighborhoodSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;

    if (!enabled || cityCode == null || districtName == null) {
      return const SizedBox.shrink();
    }

    final params = FetchNeighborhoodsParams(
      cityCode: cityCode!,
      districtName: districtName!,
    );
    final neighborhoodsAsync = ref.watch(fetchNeighborhoodsProvider(params));

    return neighborhoodsAsync.when(
      data: (response) {
        if (response.neighborhoods.isEmpty) {
          return const SizedBox.shrink();
        }
        return ReactiveDropdownField<String>(
          formControlName: 'postalCode',
          decoration: InputDecoration(
            labelText: "Neighborhood".tr,
            hintText: "Select Neighborhood".tr,
            filled: true,
            fillColor: AppColor.primary2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          items: response.neighborhoods
              .map((n) => DropdownMenuItem<String>(
                    value: n.getLocalizedName(langCode),
                    child: Text(n.getLocalizedName(langCode)),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              final neighborhood = response.neighborhoods.firstWhere(
                (n) => n.getLocalizedName(langCode) == value,
                orElse: () => response.neighborhoods.first,
              );
              onNeighborhoodSelected(neighborhood);
            }
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
