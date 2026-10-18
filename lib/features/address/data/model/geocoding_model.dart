class GeocodingModel {
  final String displayName;
  final String lat;
  final String lon;
  final GeocodingAddress address;

  GeocodingModel({
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.address,
  });

  factory GeocodingModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>?;
    if (result == null) {
      throw Exception('Invalid geocoding response');
    }

    return GeocodingModel(
      displayName: result['display_name'] as String? ?? '',
      lat: result['lat'] as String? ?? '',
      lon: result['lon'] as String? ?? '',
      address: GeocodingAddress.fromJson(
        result['address'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class GeocodingAddress {
  final String? road;
  final String? suburb;
  final String? city;
  final String? town;
  final String? province;
  final String? region;
  final String? postcode;
  final String? country;
  final String? countryCode;

  GeocodingAddress({
    this.road,
    this.suburb,
    this.city,
    this.town,
    this.province,
    this.region,
    this.postcode,
    this.country,
    this.countryCode,
  });

  factory GeocodingAddress.fromJson(Map<String, dynamic> json) {
    return GeocodingAddress(
      road: json['road'] as String?,
      suburb: json['suburb'] as String?,
      city: json['city'] as String?,
      town: json['town'] as String?,
      province: json['province'] as String?,
      region: json['region'] as String?,
      postcode: json['postcode'] as String?,
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  String get locationName {
    return city ?? town ?? province ?? region ?? country ?? 'Unknown location';
  }

  String get fullAddress {
    final parts = <String>[];
    
    if (road != null && road!.isNotEmpty) parts.add(road!);
    if (suburb != null && suburb!.isNotEmpty) parts.add(suburb!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (town != null && town!.isNotEmpty && city != town) parts.add(town!);
    if (province != null && province!.isNotEmpty && province != city) {
      parts.add(province!);
    }
    if (postcode != null && postcode!.isNotEmpty) parts.add(postcode!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    
    return parts.join(', ');
  }
}



