class CategoryModel {
  final int index;
  final String name;
  final String image;

  CategoryModel({
    required this.index,
    required this.name,
    required this.image,
  });
}

List<CategoryModel> dummyCategories = [
  CategoryModel(
    index: 0,
    name: "Auctions",
    image: "assets/base/auctions.png",
  ),
  CategoryModel(
    index: 1,
    name: "Showrooms",
    image: "assets/base/show_rooms.png",
  ),
  CategoryModel(
    index: 2,
    name: "Service Center",
    image: "assets/base/services_center.png",
  ),
  CategoryModel(
    index: 3,
    name: "Rental",
    image: "assets/base/rental.png",
  ),
  CategoryModel(
    index: 4,
    name: "Fund",
    image: "assets/base/fund.png",
  ),
  CategoryModel(
    index: 5,
    name: "Car Parts",
    image: "assets/base/parts.jpg",
  ),
  CategoryModel(
    index: 6,
    name: "Grand prize",
    image: "assets/base/car.jpg",
  ),
];

