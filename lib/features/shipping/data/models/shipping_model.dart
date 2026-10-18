class ShippingCompanyModel {
  final String companyId;
  final String companyName;
  final String? companyNameTr;
  final String? companyNameAr;
  final double price;
  final EstimatedDays? estimatedDays;
  final double? freeShippingThreshold;

  ShippingCompanyModel({
    required this.companyId,
    required this.companyName,
    this.companyNameTr,
    this.companyNameAr,
    required this.price,
    this.estimatedDays,
    this.freeShippingThreshold,
  });

  factory ShippingCompanyModel.fromJson(Map<String, dynamic> json) {
    return ShippingCompanyModel(
      companyId: json['companyId']?.toString() ?? json['_id']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      companyNameTr: json['companyNameTr']?.toString(),
      companyNameAr: json['companyNameAr']?.toString(),
      price: json['price'] is num 
          ? json['price'].toDouble() 
          : (json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0),
      estimatedDays: json['estimatedDays'] != null 
          ? EstimatedDays.fromJson(json['estimatedDays']) 
          : null,
      freeShippingThreshold: json['freeShippingThreshold'] is num
          ? json['freeShippingThreshold'].toDouble()
          : (json['freeShippingThreshold'] != null 
              ? double.tryParse(json['freeShippingThreshold'].toString()) 
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      if (companyNameTr != null) 'companyNameTr': companyNameTr,
      if (companyNameAr != null) 'companyNameAr': companyNameAr,
      'price': price,
      if (estimatedDays != null) 'estimatedDays': estimatedDays!.toJson(),
      if (freeShippingThreshold != null) 'freeShippingThreshold': freeShippingThreshold,
    };
  }
}

class EstimatedDays {
  final int min;
  final int max;

  EstimatedDays({
    required this.min,
    required this.max,
  });

  factory EstimatedDays.fromJson(Map<String, dynamic> json) {
    return EstimatedDays(
      min: json['min'] is int ? json['min'] : (int.tryParse(json['min']?.toString() ?? '0') ?? 0),
      max: json['max'] is int ? json['max'] : (int.tryParse(json['max']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
    };
  }
}

class ShippingCalculationRequest {
  final String countryCode;
  final String provinceCode;
  final double orderTotal;
  final String? vendorId;

  ShippingCalculationRequest({
    required this.countryCode,
    required this.provinceCode,
    required this.orderTotal,
    this.vendorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'provinceCode': provinceCode,
      'orderTotal': orderTotal,
      if (vendorId != null) 'vendorId': vendorId,
    };
  }
}

