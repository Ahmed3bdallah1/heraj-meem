import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/features/search/data/data_source/baho_search_data_source.dart';
import 'package:heraj_meem/features/search/domain/entities/search_ads_page.dart';
import 'package:heraj_meem/features/search/domain/repo/baho_search_repo.dart';

class BahoSearchRepoImp extends BahoSearchRepo {
  BahoSearchRepoImp({required this.dataSource});

  final BahoSearchDataSource dataSource;

  @override
  Future<Either<Failure, SearchAdsPage>> searchAds(SearchAdsParam param) async {
    try {
      final page = await dataSource.searchAds(param);
      return Right(page);
    } catch (error) {
      if (error is DioException) return Left(ServerFailure.fromDioError(error));
      return Left(GeneralError(error));
    }
  }
}
