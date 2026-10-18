import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/location_service/location_provider.dart';
import 'package:heraj_meem/core/service/location_service/location_service.dart';
import 'package:heraj_meem/features/home/presentation/view/widgets/location_bottom_sheet.dart';
import 'package:heraj_meem/gen/assets.gen.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:location/location.dart';

/// Bottom sheet for requesting location permission after login
Future<LocationDetails?> showLocationRequestBottomSheet({
  BuildContext? context,
}) async {
  return await showModalBottomSheet<LocationDetails?>(
    context: Get.context ?? context!,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const LocationRequestBottomSheet(),
  );
}

class LocationRequestBottomSheet extends ConsumerStatefulWidget {
  const LocationRequestBottomSheet({super.key});

  @override
  ConsumerState<LocationRequestBottomSheet> createState() =>
      _LocationRequestBottomSheetState();
}

class _LocationRequestBottomSheetState
    extends ConsumerState<LocationRequestBottomSheet> {
  bool _isLoadingLocation = false;

  Future<void> _requestCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final locationService = getIt<LocationService>();
      final location = Location();

      // Check if location services are enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          if (mounted) {
            _showLocationError('Location services are disabled'.tr);
          }
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      // Check location permission
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          if (mounted) {
            _showLocationError('Location permission denied'.tr);
          }
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      // Get current location
      final locationDetails = await locationService.getCurrentLocation();

      if (locationDetails != null) {
        ref
            .read(currentDisplayLocationProvider.notifier)
            .state =
            locationDetails;
        ref.invalidate(fetchLocationDetailsProvider);

        if (mounted) {
          Navigator.pop(context, locationDetails);
        }
      } else {
        if (mounted) {
          _showLocationError('Unable to get current location'.tr);
        }
      }
    } catch (e) {
      if (mounted) {
        _showLocationError('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.danger,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _skipLocationSelection() {
    Navigator.pop(context, null);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    return Container(
      height: size.height * 0.55,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Map background image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  Assets.base.location.path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColor.grey1.withAlpha(50),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.map_outlined,
                          size: 100,
                          color: AppColor.grey2,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: _skipLocationSelection,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: AppColor.grey2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withAlpha(75),
                  Colors.white.withAlpha(240),
                ],
                stops: const [0.0, 0.6],
              ),
            ),
          ),

          // Content
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'We need to access your location'.tr,
                  style: AppFont.font18W700Black.copyWith(
                    color: AppColor.primary,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Gap(10),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CustomFilledButton(
                        isLoading: _isLoadingLocation,
                        onPressed: _isLoadingLocation
                            ? null
                            : _requestCurrentLocation,
                        text: 'Allow Location Access'.tr,
                      ),
                    ),
                    const Gap(16),
                    TextButton(
                      onPressed: _isLoadingLocation
                          ? null
                          : _skipLocationSelection,
                      child: Text(
                        "Don't Allow".tr,
                        style: AppFont.font14W600Grey2,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(10),

              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.grey2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Gap(MediaQuery.of(context).padding.bottom),
            ],
          ),
        ],
      ),
    );
  }
}

