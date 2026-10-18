import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../store/data/models/open_store_model.dart';
import '../../domain/repo/categories_repo.dart';
import '../data_source/categories_data_source.dart';
import '../models/main_category_model.dart';

class CategoriesRepoImpl extends CategoriesRepo {
  final CategoriesDataSource dataSource;

  CategoriesRepoImpl(this.dataSource);

  @override
  Future<Either<Failure, List<CategoryModel>>> getFeaturedCategories() async {
    try {
      final response = await dataSource.getFeaturedCategories();
      return Right(response);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getAllCategories() async {
    try {
      final response = await dataSource.getAllCategories();
      return Right(response);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategoriesTree() async {
    try {
      final response = await dataSource.getCategoriesTree();
      return Right(response);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getAdminCategoriesTree() async {
    try {
      final response = await dataSource.getAllAdminCategories();
      return Right(response);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, StoreCategoryDetailsModel>> getCategoryDetails(
      String catId) async {
    try {
      final response = await dataSource.getCategoryDetails(catId);
      return Right(response);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}
