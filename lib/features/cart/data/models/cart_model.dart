import 'cart_item_model.dart';

class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double totalPrice;
  final String createdAt;
  final String updatedAt;
  final int v;

  CartModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // Handle items array
    final itemsList = json["items"] as List?;
    final items = itemsList != null
        ? itemsList.map((e) => CartItemModel.fromJson(e)).toList()
        : <CartItemModel>[];

    // Handle totalPrice
    final totalPrice = json["totalPrice"] != null
        ? (json["totalPrice"] is int
            ? json["totalPrice"].toDouble()
            : (json["totalPrice"] as num?)?.toDouble() ?? 0.0)
        : 0.0;

    return CartModel(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? '',
      userId: json["userId"]?.toString() ?? '',
      items: items,
      totalPrice: totalPrice,
      createdAt: json["createdAt"]?.toString() ?? '',
      updatedAt: json["updatedAt"]?.toString() ?? '',
      v: json["__v"] is int
          ? json["__v"]
          : (int.tryParse(json["__v"]?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "id": id,
      "userId": userId,
      "items": items.map((e) => e.toJson()).toList(),
      "totalPrice": totalPrice,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
    };
  }

  /// Get total quantity of all items in cart
  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  }

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;
}
