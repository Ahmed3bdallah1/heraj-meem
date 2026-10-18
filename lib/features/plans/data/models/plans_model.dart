import '../../../../core/service/localization_service/localization_service.dart';

class PlanFeaturesObj {
  final bool aiAssistant;
  final bool prioritySupport;
  final int featuredListings;
  final bool analytics;
  final bool verifiedBadge;

  const PlanFeaturesObj({
    required this.aiAssistant,
    required this.prioritySupport,
    required this.featuredListings,
    required this.analytics,
    required this.verifiedBadge,
  });

  factory PlanFeaturesObj.fromJson(Map<String, dynamic> json) => PlanFeaturesObj(
        aiAssistant: json["aiAssistant"] ?? false,
        prioritySupport: json["prioritySupport"] ?? false,
        featuredListings: json["featuredListings"] ?? 0,
        analytics: json["analytics"] ?? false,
        verifiedBadge: json["verifiedBadge"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "aiAssistant": aiAssistant,
        "prioritySupport": prioritySupport,
        "featuredListings": featuredListings,
        "analytics": analytics,
        "verifiedBadge": verifiedBadge,
      };
}

class PlanLimits {
  final int globalLimit;
  final int categoryLimit;

  const PlanLimits({
    required this.globalLimit,
    required this.categoryLimit,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> json) => PlanLimits(
        globalLimit: json["globalLimit"] ?? 0,
        categoryLimit: json["categoryLimit"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "globalLimit": globalLimit,
        "categoryLimit": categoryLimit,
      };

  // Helper to check if unlimited
  bool get isUnlimited => globalLimit == -1;
  
  // Backward compatibility
  int get maxProducts => globalLimit;
  int get featuredProducts => 0; // Not in new API, use featuresObj.featuredListings instead
}

class PlanModel {
  final String id;
  final String name;
  final String? nameTr;
  final String? nameAr;
  final double price;
  final String currency;
  final String period;
  final int duration;
  final PlanLimits limits;
  final List<String> features;
  final PlanFeaturesObj featuresObj;
  final String? description;
  final String? descriptionTr;
  final String? descriptionAr;
  final bool popular;

  // Optional fields for backward compatibility with UI
  final String? icon;
  final bool? isActive;
  final bool? isFree;
  final int? colorHex;

  const PlanModel({
    required this.id,
    required this.name,
    this.nameTr,
    this.nameAr,
    required this.price,
    required this.currency,
    required this.period,
    required this.duration,
    required this.limits,
    required this.features,
    required this.featuresObj,
    this.description,
    this.descriptionTr,
    this.descriptionAr,
    this.popular = false,
    this.icon,
    this.isActive,
    this.isFree,
    this.colorHex,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        nameTr: json["nameTr"],
        nameAr: json["nameAr"],
        price: (json["price"] is int)
            ? (json["price"] as int).toDouble()
            : (json["price"] as num?)?.toDouble() ?? 0.0,
        currency: json["currency"] ?? "TRY",
        period: json["period"] ?? "month",
        duration: json["duration"] ?? 30,
        limits: PlanLimits.fromJson(json),
        features: (json["features"] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        featuresObj: PlanFeaturesObj.fromJson(
            json["featuresObj"] as Map<String, dynamic>? ?? {}),
        description: json["description"],
        descriptionTr: json["descriptionTr"],
        descriptionAr: json["descriptionAr"],
        popular: json["popular"] ?? false,
        icon: json["icon"],
        isActive: json["isActive"] ?? json["is_active"],
        isFree: json["isFree"] ??
            json["is_free"] ??
            (json["price"] == 0 || json["price"] == 0.0),
        colorHex: json["colorHex"] ?? json["color_hex"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        if (nameTr != null) "nameTr": nameTr,
        if (nameAr != null) "nameAr": nameAr,
        "price": price,
        "currency": currency,
        "period": period,
        "duration": duration,
        "globalLimit": limits.globalLimit,
        "categoryLimit": limits.categoryLimit,
        "features": features,
        "featuresObj": featuresObj.toJson(),
        if (description != null) "description": description,
        if (descriptionTr != null) "descriptionTr": descriptionTr,
        if (descriptionAr != null) "descriptionAr": descriptionAr,
        "popular": popular,
        if (icon != null) "icon": icon,
        if (isActive != null) "isActive": isActive,
        if (isFree != null) "isFree": isFree,
        if (colorHex != null) "colorHex": colorHex,
      };

  // Getters for localized names
  String getLocalizedName() {
    final locale = localeService.handleLocaleInMain;
    if (locale.languageCode == 'tr' && nameTr != null && nameTr!.isNotEmpty) {
      return nameTr!;
    } else if (locale.languageCode == 'ar' && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  String? getLocalizedDescription() {
    final locale = localeService.handleLocaleInMain;
    if (locale.languageCode == 'tr' && descriptionTr != null && descriptionTr!.isNotEmpty) {
      return descriptionTr!;
    } else if (locale.languageCode == 'ar' && descriptionAr != null && descriptionAr!.isNotEmpty) {
      return descriptionAr!;
    }
    return description;
  }

  // Getters for backward compatibility with existing UI
  String get title => getLocalizedName();
  String get priceString => price == 0 ? "0" : price.toStringAsFixed(2);
  bool get freeCredits => false; // Not in new API, default to false
  bool get maxTeamMembers => false; // Not in new API, default to false
  bool get dedicatedSupport => featuresObj.prioritySupport;
  int get sortOrder => popular ? 1 : 0; // Popular plans first
  int get credits => 0; // Not in new API, default to 0

  // Helper method to get display description
  String getDisplayDescription() {
    final localizedDesc = getLocalizedDescription();
    if (localizedDesc != null && localizedDesc.isNotEmpty) {
      return localizedDesc;
    }
    // Generate description from limits
    if (limits.isUnlimited) {
      return "Unlimited Products";
    }
    return "${limits.globalLimit} Products, ${limits.categoryLimit} per Category";
  }

  // Get currency symbol
  String getCurrencySymbol() {
    switch (currency.toUpperCase()) {
      case 'TRY':
      case 'TL':
        return '₺';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return currency;
    }
  }
}

class MySubscriptionModel {
  final PlanModel? currentSubscription;
  final List<PlanModel> history;

  const MySubscriptionModel({
    this.currentSubscription,
    required this.history,
  });

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MySubscriptionModel(
      currentSubscription: json['currentSubscription'] != null
          ? PlanModel.fromJson(json['currentSubscription'] as Map<String, dynamic>)
          : null,
      history: (json['history'] as List<dynamic>?)
              ?.map((item) => PlanModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        if (currentSubscription != null)
          'currentSubscription': currentSubscription!.toJson(),
        'history': history.map((plan) => plan.toJson()).toList(),
      };
}
