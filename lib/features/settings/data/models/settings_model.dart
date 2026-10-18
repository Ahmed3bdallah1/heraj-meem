class SettingsModel {
  final double shippingPrice;

  SettingsModel({
    required this.shippingPrice,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      shippingPrice: json["shipping_cost"] is String
          ? double.parse(json["shipping_cost"] ?? "0.0")
          : json["shipping_cost"] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        "shipping_cost": shippingPrice,
      };
}
