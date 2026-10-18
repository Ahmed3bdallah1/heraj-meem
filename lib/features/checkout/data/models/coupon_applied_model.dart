
class CouponAppliedModel {
  final CouponModel? coupon;
  final List<CouponCartItemModel> items;
  final double subtotal;
  final double discount;
  final double total;

  CouponAppliedModel({
    this.coupon,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  factory CouponAppliedModel.fromJson(Map<String, dynamic> json) {
    return CouponAppliedModel(
      coupon: json['coupon'] != null ? CouponModel.fromJson(json['coupon']) : null,
      items: (json['items'] as List?)
              ?.map((item) => CouponCartItemModel.fromJson(item))
              .toList() ?? [],
      subtotal: json['subtotal'] is double
          ? json['subtotal']
          : (json['subtotal'] is int
              ? json['subtotal'].toDouble()
              : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0),
      discount: json['discount'] is double
          ? json['discount']
          : (json['discount'] is int
              ? json['discount'].toDouble()
              : double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0),
      total: json['total'] is double
          ? json['total']
          : (json['total'] is int
              ? json['total'].toDouble()
              : double.tryParse(json['total']?.toString() ?? '0') ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() => {
        'coupon': coupon?.toJson(),
        'items': items.map((item) => item.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
      };
}

class CouponModel {
  final int id;
  final String code;
  final String type;
  final String value;

  CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'type': type,
        'value': value,
      };
}

class CouponCartItemModel {
  final int id;
  final CouponProductModel product;
  final int quantity;
  final double subtotal;

  CouponCartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  factory CouponCartItemModel.fromJson(Map<String, dynamic> json) {
    return CouponCartItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      product: CouponProductModel.fromJson(json['product']),
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      subtotal: json['subtotal'] is double
          ? json['subtotal']
          : (json['subtotal'] is int
              ? json['subtotal'].toDouble()
              : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product': product.toJson(),
        'quantity': quantity,
        'subtotal': subtotal,
      };
}

class CouponProductModel {
  final int id;
  final String name;
  final String description;
  final String price;
  final String beforePrice;
  final String thumbImage;

  CouponProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.beforePrice,
    required this.thumbImage,
  });

  factory CouponProductModel.fromJson(Map<String, dynamic> json) {
    return CouponProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      beforePrice: json['before_price']?.toString() ?? '0',
      thumbImage: json['thumb_image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'before_price': beforePrice,
        'thumb_image': thumbImage,
      };
}

