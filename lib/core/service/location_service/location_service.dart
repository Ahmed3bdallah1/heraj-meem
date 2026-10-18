import 'package:location/location.dart';
import 'package:tuple/tuple.dart';
import '../../../features/address/domain/use_case/address_use_cases.dart';

class LocationDetails {
  const LocationDetails({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.fullAddress,
  });

  final double latitude;
  final double longitude;
  final String name;
  final String fullAddress;
}

class LocationService {
  LocationService({
    Location? location,
    required this.reverseGeocodeUseCase,
  }) : _location = location ?? Location();

  final Location _location;
  final ReverseGeocodeUseCase reverseGeocodeUseCase;

  Future<LocationDetails?> getCurrentLocation() async {
    try {
      final serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) return null;

      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 10,
      );

      final locationData = await _location.getLocation();
      final latitude = locationData.latitude;
      final longitude = locationData.longitude;

      if (latitude == null || longitude == null) {
        final retryData = await _location.getLocation();
        final retryLat = retryData.latitude;
        final retryLng = retryData.longitude;

        if (retryLat == null || retryLng == null) return null;

        return await _geocodeLocation(retryLat, retryLng);
      }

      return await _geocodeLocation(latitude, longitude);
    } catch (e) {
      // Log error for debugging
      print('LocationService error: $e');
      return null;
    }
  }

  Future<LocationDetails> _geocodeLocation(
      double latitude, double longitude) async {
    try {
      final result = await reverseGeocodeUseCase.call(Tuple2(latitude, longitude));

      return result.fold(
        (failure) {
          print('Reverse geocoding error: ${failure.message}');
          return LocationDetails(
            latitude: latitude,
            longitude: longitude,
            name: 'Current location',
            fullAddress: '$latitude, $longitude',
          );
        },
        (geocoding) {
          print('Geocoding success:');
          print('  display_name: ${geocoding.displayName}');
          print('  city: ${geocoding.address.city}');
          print('  country: ${geocoding.address.country}');

          final name = geocoding.address.locationName;
          final address = geocoding.address.fullAddress;

          return LocationDetails(
            latitude: latitude,
            longitude: longitude,
            name: name.isNotEmpty ? name : 'Current location',
            fullAddress: address.isNotEmpty ? address : '$latitude, $longitude',
          );
        },
      );
    } catch (e, stackTrace) {
      print('Geocoding error: $e');
      print('Stack trace: $stackTrace');
      return LocationDetails(
        latitude: latitude,
        longitude: longitude,
        name: 'Current location',
        fullAddress: '$latitude, $longitude',
      );
    }
  }
}
