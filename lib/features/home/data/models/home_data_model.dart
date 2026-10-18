import 'package:heraj/features/home/domain/entities/ad_entity.dart';
import 'package:heraj/features/categories/data/models/main_category_model.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/store/data/models/store_model.dart';
import 'package:heraj/features/stories/data/models/story_model.dart';

class HomeDataModel {
  final List<StoryModel> stories;
  final List<AdEntity> sliders;
  final List<CategoryModel> categories;
  final List<ProductModel> realEstate;
  final List<ProductModel> latestProducts;
  final List<ProductModel> hotDeals;
  final List<ProductModel> adminProducts;
  final List<StoreModel> topStores;

  HomeDataModel({
    required this.stories,
    required this.sliders,
    required this.categories,
    required this.realEstate,
    required this.latestProducts,
    required this.hotDeals,
    required this.adminProducts,
    required this.topStores,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      stories: (json['stories'] as List?)
              ?.map((item) => StoryModel.fromJson(
                  item is Map<String, dynamic> ? item : null))
              .toList() ??
          [],
      sliders: () {
        final slidersList = (json['sliders'] as List?)
                ?.map((item) => AdEntity.fromJson(
                    item is Map<String, dynamic> ? item : null))
                .where((item) => item.isActive)
                .toList() ??
            [];
        slidersList.sort((a, b) => a.order.compareTo(b.order));
        return slidersList;
      }(),
      categories: (json['categories'] as List?)
              ?.map((item) => CategoryModel.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
      realEstate: (json['realEstate'] as List?)
              ?.map((item) => ProductModel.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
      latestProducts: (json['latestProducts'] as List?)
              ?.map((item) => ProductModel.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
      hotDeals: (json['hotDeals'] as List?)
              ?.map((item) => ProductModel.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
      adminProducts: (json['adminProducts'] as List?)
              ?.map((item) => ProductModel.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
      topStores: (json['topStores'] as List?)
              ?.map((item) =>
                  StoreModel.fromJson(item is Map<String, dynamic> ? item : {}))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stories': stories.map((item) => item.toJson()).toList(),
      'sliders': sliders.map((item) => item.toJson()).toList(),
      'categories': categories.map((item) => item.toJson()).toList(),
      'realEstate': realEstate.map((item) => item.toJson()).toList(),
      'latestProducts': latestProducts.map((item) => item.toJson()).toList(),
      'hotDeals': hotDeals.map((item) => item.toJson()).toList(),
      'adminProducts': adminProducts.map((item) => item.toJson()).toList(),
      'topStores': topStores.map((item) => item.toJson()).toList(),
    };
  }
}
