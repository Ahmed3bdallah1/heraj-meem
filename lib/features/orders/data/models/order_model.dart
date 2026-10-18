import 'package:heraj/features/address/data/model/address_model.dart';
import 'package:heraj/features/products/data/models/product_model.dart';


class OrdersPaginatedModel {
  final bool success;
  final List<OrderModel> data;
  final OrderPagination? pagination;

  OrdersPaginatedModel({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory OrdersPaginatedModel.fromJson(Map<String, dynamic> json) {
    return OrdersPaginatedModel(
      success: json['success'] ?? true,
      data: (json['data'] as List?)
          ?.map((item) => OrderModel.fromJson(item))
          .toList() ?? [],
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? OrderPagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class OrderPagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  OrderPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory OrderPagination.fromJson(Map<String, dynamic> json) {
    return OrderPagination(
      page: json['page'] is int ? json['page'] : (int.tryParse(json['page']?.toString() ?? '0') ?? 0),
      limit: json['limit'] is int ? json['limit'] : (int.tryParse(json['limit']?.toString() ?? '0') ?? 0),
      total: json['total'] is int ? json['total'] : (int.tryParse(json['total']?.toString() ?? '0') ?? 0),
      totalPages: json['totalPages'] is int ? json['totalPages'] : (int.tryParse(json['totalPages']?.toString() ?? '0') ?? 0),
      hasMore: json['hasMore'] ?? false,
    );
  }
}

class OrderModel {
  final String id;
  final String? orderNumber;
  final String? customerId;
  final String? status;
  final double? totalPrice;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? createdAt;
  final String? updatedAt;
  final List<OrderItemModel> items;
  final DeliveryAddress? deliveryAddress;
  // New price breakdown fields
  final double? subtotal;
  final double? shippingCost;
  final double? tax;
  final double? taxRate;
  final OrderShipping? shipping;
  // Legacy fields for backward compatibility
  final String? userId;
  final String? total;
  final String? discount;
  final String? couponId;
  final String? couponDiscountValue;
  final String? finalTotal;
  final String? shippingAddressId;
  final String? billingAddressId;
  final AddressModel? shippingAddress;
  final AddressModel? billingAddress;
  final List<OrderPrescriptionModel> prespictions;
  final OrderCouponModel? coupon;

  OrderModel({
    required this.id,
    this.orderNumber,
    this.customerId,
    this.status,
    this.totalPrice,
    this.paymentStatus,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.deliveryAddress,
    // New price breakdown fields
    this.subtotal,
    this.shippingCost,
    this.tax,
    this.taxRate,
    this.shipping,
    // Legacy fields
    this.userId,
    this.total,
    this.discount,
    this.couponId,
    this.couponDiscountValue,
    this.finalTotal,
    this.shippingAddressId,
    this.billingAddressId,
    this.shippingAddress,
    this.billingAddress,
    this.prespictions = const [],
    this.coupon,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString(),
      customerId: json['customerId']?.toString(),
      status: json['status']?.toString(),
      totalPrice: json['totalPrice'] is num ? json['totalPrice'].toDouble() : (json['totalPrice'] != null ? double.tryParse(json['totalPrice'].toString()) : null),
      paymentStatus: json['paymentStatus']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      items: (json['items'] as List?)
              ?.map((e) => OrderItemModel.fromJson(e))
              .toList() ??
          [],
      deliveryAddress: json['deliveryAddress'] != null && json['deliveryAddress'] is Map<String, dynamic>
          ? DeliveryAddress.fromJson(json['deliveryAddress'])
          : null,
      // New price breakdown fields
      subtotal: json['subtotal'] is num ? json['subtotal'].toDouble() : (json['subtotal'] != null ? double.tryParse(json['subtotal'].toString()) : null),
      shippingCost: json['shippingCost'] is num ? json['shippingCost'].toDouble() : (json['shippingCost'] != null ? double.tryParse(json['shippingCost'].toString()) : (json['shipping_cost'] != null ? double.tryParse(json['shipping_cost'].toString()) : null)),
      tax: json['tax'] is num ? json['tax'].toDouble() : (json['tax'] != null ? double.tryParse(json['tax'].toString()) : null),
      taxRate: json['taxRate'] is num ? json['taxRate'].toDouble() : (json['taxRate'] != null ? double.tryParse(json['taxRate'].toString()) : null),
      shipping: json['shipping'] != null && json['shipping'] is Map<String, dynamic>
          ? OrderShipping.fromJson(json['shipping'])
          : null,
      // Legacy fields
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? json['customerId']?.toString(),
      total: json['total']?.toString() ?? json['totalPrice']?.toString(),
      discount: json['discount']?.toString(),
      couponId: json['coupon_id']?.toString(),
      couponDiscountValue: json['coupon_discount_value']?.toString(),
      finalTotal: json['final_total']?.toString() ?? json['totalPrice']?.toString(),
      shippingAddressId: json['shipping_address_id']?.toString(),
      billingAddressId: json['billing_address_id']?.toString(),
      shippingAddress: json['shipping_address'] != null
          ? AddressModel.fromJson(json['shipping_address'])
          : null,
      billingAddress: json['billing_address'] != null
          ? AddressModel.fromJson(json['billing_address'])
          : null,
      prespictions: (json['prespictions'] as List?)
              ?.map((e) => OrderPrescriptionModel.fromJson(e))
              .toList() ??
          [],
      coupon: json['coupon'] != null ? OrderCouponModel.fromJson(json['coupon']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'total': total,
      'discount': discount,
      'shipping_cost': shippingCost,
      'coupon_id': couponId,
      'coupon_discount_value': couponDiscountValue,
      'final_total': finalTotal,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'shipping_address_id': shippingAddressId,
      'billing_address_id': billingAddressId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'items': items.map((e) => e.toJson()).toList(),
      'shipping_address': shippingAddress?.toJson(),
      'billing_address': billingAddress?.toJson(),
      'prespictions': prespictions.map((e) => e.toJson()).toList(),
      'coupon': coupon?.toJson(),
    }..removeWhere((key, value) => value == null);
  }
}

class OrderItemModel {
  final String id;
  final String? orderId;
  final String? productId;
  final String? title;
  final int? quantity;
  final double? price;
  final String? createdAt;
  final String? updatedAt;
  final ProductInfo? productInfo;
  final ProductModel? product;

  OrderItemModel({
    required this.id,
    this.orderId,
    this.productId,
    this.title,
    this.quantity,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.productInfo,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString(),
      productId: json['productId'] != null && json['productId'] is Map<String, dynamic>
          ? (json['productId']['_id']?.toString() ?? json['productId']['id']?.toString())
          : (json['product_id']?.toString() ?? json['productId']?.toString()),
      title: json['title']?.toString(),
      quantity: json['quantity'] is int ? json['quantity'] : (json['quantity'] != null ? int.tryParse(json['quantity'].toString()) : null),
      price: json['price'] is num ? json['price'].toDouble() : (json['price'] != null ? double.tryParse(json['price'].toString()) : null),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      updatedAt: json['updated_at']?.toString() ?? json['updatedAt']?.toString(),
      productInfo: json['productId'] != null && json['productId'] is Map<String, dynamic>
          ? ProductInfo.fromJson(json['productId'])
          : null,
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product': product?.toJson(),
    }..removeWhere((key, value) => value == null);
  }
}

class OrderPrescriptionModel {
  final int id;
  final String? orderId;
  final String? image;
  final String? createdAt;
  final String? updatedAt;
  final String? fileUrl;

  OrderPrescriptionModel({
    required this.id,
    this.orderId,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.fileUrl,
  });

  factory OrderPrescriptionModel.fromJson(Map<String, dynamic> json) {
    return OrderPrescriptionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      orderId: json['order_id']?.toString(),
      image: json['image']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      fileUrl: json['file_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'file_url': fileUrl,
    }..removeWhere((key, value) => value == null);
  }
}


class OrderCouponModel {
  final int id;
  final String? code;
  final CouponDescription? description;
  final String? type;
  final String? couponDiscountValue;
  final String? minCartAmount;
  final String? usageLimit;
  final String? usedCount;
  final String? startDate;
  final String? endDate;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;

  OrderCouponModel({
    required this.id,
    this.code,
    this.description,
    this.type,
    this.couponDiscountValue,
    this.minCartAmount,
    this.usageLimit,
    this.usedCount,
    this.startDate,
    this.endDate,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderCouponModel.fromJson(Map<String, dynamic> json) {
    return OrderCouponModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: json['code']?.toString(),
      description: (() {
        final raw = json['description'];
        if (raw == null) return null;
        if (raw is Map<String, dynamic>) {
          return CouponDescription.fromJson(raw);
        }
        // Some APIs return description as a plain string
        final str = raw.toString();
        return CouponDescription(ar: str.isEmpty ? null : str);
      })(),
      type: json['type']?.toString(),
      couponDiscountValue: json['coupon_discount_value']?.toString(),
      minCartAmount: json['min_cart_amount']?.toString(),
      usageLimit: json['usage_limit']?.toString(),
      usedCount: json['used_count']?.toString(),
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      isActive: json['is_active'] is bool
          ? json['is_active']
          : (json['is_active']?.toString().toLowerCase() == 'true' || json['is_active']?.toString() == '1'),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description?.toJson(),
      'type': type,
      'coupon_discount_value': couponDiscountValue,
      'min_cart_amount': minCartAmount,
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'start_date': startDate,
      'end_date': endDate,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    }..removeWhere((key, value) => value == null);
  }
}

class CouponDescription {
  final String? ar;

  CouponDescription({this.ar});

  factory CouponDescription.fromJson(Map<String, dynamic> json) {
    return CouponDescription(
      ar: json['ar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ar': ar,
    }..removeWhere((key, value) => value == null);
  }
}

class ProductInfo {
  final String id;
  final String? title;
  final List<String> images;

  ProductInfo({
    required this.id,
    this.title,
    this.images = const [],
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      images: (json['images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'images': images,
    }..removeWhere((key, value) => value == null);
  }
}

class DeliveryAddress {
  final List<dynamic> coordinates;

  DeliveryAddress({
    this.coordinates = const [],
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      coordinates: json['coordinates'] as List? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinates': coordinates,
    };
  }
}

class OrderShipping {
  final String? companyName;
  final String? trackingNumber;

  OrderShipping({
    this.companyName,
    this.trackingNumber,
  });

  factory OrderShipping.fromJson(Map<String, dynamic> json) {
    return OrderShipping(
      companyName: json['companyName']?.toString(),
      trackingNumber: json['trackingNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (companyName != null) 'companyName': companyName,
      if (trackingNumber != null) 'trackingNumber': trackingNumber,
    };
  }
}


