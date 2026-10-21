import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';

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
  }) : _location = location ?? Location();

  final Location _location;

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
      final marks = await geo.placemarkFromCoordinates(latitude, longitude);
      if (marks.isEmpty) return _fallbackLocation(latitude, longitude);

      final place = marks.first;
      final name = _firstFilled([
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.name,
      ]);
      final address = _joinAddress([
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ]);

      return LocationDetails(
        latitude: latitude,
        longitude: longitude,
        name: name.isNotEmpty ? name : 'Current location',
        fullAddress: address.isNotEmpty ? address : '$latitude, $longitude',
      );
    } catch (e, stackTrace) {
      print('Geocoding error: $e');
      print('Stack trace: $stackTrace');
      return _fallbackLocation(latitude, longitude);
    }
  }

  LocationDetails _fallbackLocation(double latitude, double longitude) {
    return LocationDetails(
      latitude: latitude,
      longitude: longitude,
      name: 'Current location',
      fullAddress: '$latitude, $longitude',
    );
  }

  String _firstFilled(List<String?> parts) {
    for (final part in parts) {
      final text = part?.trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _joinAddress(List<String?> parts) {
    final seen = <String>{};
    for (final part in parts) {
      final text = part?.trim() ?? '';
      if (text.isNotEmpty) seen.add(text);
    }
    return seen.join(', ');
  }
}
