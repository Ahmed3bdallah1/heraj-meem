import '../../../products/data/models/product_model.dart';

class CartItemModel {
  final String? id;
  final ProductModel? product;
  final int? quantity;
  final double? subtotal;
  final double? price;

  CartItemModel({
    this.id,
    this.product,
    this.quantity,
    this.subtotal,
    this.price,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    ProductModel? product;
    String? productIdString;

    if (json["productId"] != null) {
      if (json["productId"] is Map<String, dynamic>) {
        final productIdObj = json["productId"] as Map<String, dynamic>;
        productIdString =
            productIdObj["_id"]?.toString() ?? productIdObj["id"]?.toString();

        final images = (productIdObj["images"] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final thumbImage = images.isNotEmpty ? images[0] : '';

        product = ProductModel(
          id: productIdString ?? '',
          name: productIdObj["title"]??"",
          sku: '',
          afterPrice: (productIdObj["price"] is int
                  ? productIdObj["price"].toDouble()
                  : (productIdObj["price"] as num?)?.toDouble() ?? 0.0)
              .toString(),
          description: null,
          isFeatured: false,
          thumbImage: thumbImage,
          category: null,
          isFavorite: false,
          productType: '',
          images: images,
          badges: [],
          status: '',
          stock: productIdObj["stock"] is int
              ? productIdObj["stock"]
              : (int.tryParse(productIdObj["stock"]?.toString() ?? '0') ?? 0),
          variants: [],
          variantCombinations: [],
          isFeaturedDeal: false,
          views: 0,
          specifications: [],
          priceHistory: [],
          createdAt: '',
          updatedAt: '',
          v: 0,
        );
      } else {
        productIdString = json["productId"]?.toString();
      }
    }

    if (product == null && json["product"] != null) {
      product = ProductModel.fromJson(json["product"]);
      productIdString = product.id;
    }

    final itemPrice = json["price"] != null
        ? (json["price"] is int
            ? json["price"].toDouble()
            : (json["price"] as num?)?.toDouble() ?? 0.0)
        : null;
    final qty = json["quantity"] is int
        ? json["quantity"]
        : (int.tryParse(json["quantity"]?.toString() ?? '0') ?? 0);
    final calculatedSubtotal =
        itemPrice != null && qty > 0 ? itemPrice * qty : null;

    return CartItemModel(
      id: json["_id"]?.toString() ?? json["id"]?.toString(),
      product: product,
      quantity: qty,
      subtotal: json["subtotal"] != null
          ? (json["subtotal"] is double
              ? json["subtotal"]
              : (json["subtotal"] is int
                  ? json["subtotal"].toDouble()
                  : double.tryParse(json["subtotal"]?.toString() ?? '') ?? 0.0))
          : calculatedSubtotal,
      price: itemPrice,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "id": id,
        "productId": product?.id,
        "product": product?.toJson(),
        "quantity": quantity,
        "price": price,
        "subtotal": subtotal,
      };

  String? get productId => product?.id;
}
