class AddressModel {
  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String? city;
  final String? cityCode;
  final String? country;
  final String? state;
  final String? postalCode;
  final bool isDefault;
  final Location? location;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    this.city,
    this.cityCode,
    this.country,
    this.state,
    this.postalCode,
    this.isDefault = false,
    this.location,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? json['id'] ?? '',
      label: json['label'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'],
      cityCode: json['cityCode'],
      country: json['country'],
      state: json['state'],
      postalCode: json['postalCode'],
      isDefault: json['isDefault'] ?? false,
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'addressLine1': addressLine1,
      if (addressLine2 != null) 'addressLine2': addressLine2,
      if (city != null) 'city': city,
      if (cityCode != null) 'cityCode': cityCode,
      if (country != null) 'country': country,
      if (state != null) 'state': state,
      if (postalCode != null) 'postalCode': postalCode,
      'isDefault': isDefault,
      if (location != null) 'location': location!.toJson(),
    };
  }

  // Helper method to get full address as a single string (for backward compatibility)
  String get address => addressLine1;

  // Helper method to get name (for backward compatibility)
  String get name => fullName;

  // Helper method to get coordinates for API requests
  List<double>? get coordinates {
    return location?.coordinates;
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? 'Point',
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e is num) ? e.toDouble() : 0.0)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
