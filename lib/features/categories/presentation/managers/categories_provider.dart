import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/categories/data/models/main_category_model.dart';
import 'package:heraj/features/categories/domain/repo/categories_repo.dart';
import '../../../../main.dart';

final fetchFeaturedCategoriesProvider = FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  final res = await getIt<CategoriesRepo>().getFeaturedCategories();
  return res.fold((l)=> throw l, (r) => r);
});

final fetchAllCategoriesProvider = FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  final res = await getIt<CategoriesRepo>().getAllCategories();
  return res.fold((l)=> throw l, (r) => r);
});

final fetchCategoriesTreeProvider = FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  final res = await getIt<CategoriesRepo>().getCategoriesTree();
  return res.fold((l)=> throw l, (r) => r);
});

final fetchAdminCategoriesTreeProvider = FutureProvider.autoDispose<List<CategoryModel>>((ref) async {
  final res = await getIt<CategoriesRepo>().getAdminCategoriesTree();
  return res.fold((l)=> throw l, (r) => r);
});