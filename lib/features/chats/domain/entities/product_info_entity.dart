class ProductInfoEntity {
  final String id;
  final String title;
  final double price;
  final List<String> images;
  final String category;

  ProductInfoEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.images,
    required this.category,
  });
}

