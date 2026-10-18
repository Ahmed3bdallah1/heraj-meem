import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';

import '../../../main.dart';
import 'location_service.dart';

final fetchLocationDetailsProvider =
    FutureProvider.autoDispose<LocationDetails?>((ref) async {
  try {
    final location = Location();

    final serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    final permission = await location.hasPermission();
    final isGranted = permission == PermissionStatus.granted ||
        permission == PermissionStatus.grantedLimited;

    if (!isGranted) {
      return null;
    }
    final locationService = getIt<LocationService>();
    final details = await locationService.getCurrentLocation();
    if (details == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      return await locationService.getCurrentLocation();
    }

    return details;
  } catch (e) {
    print('LocationProvider error: $e');
    return null;
  }
});
