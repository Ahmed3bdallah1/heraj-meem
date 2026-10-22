import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/core/use_cases/use_case.dart';
import 'package:heraj_meem/features/search/domain/entities/search_ads_page.dart';
import 'package:heraj_meem/features/search/domain/repo/baho_search_repo.dart';

class SearchAdsUseCase extends UseCaseParam<SearchAdsPage, SearchAdsParam> {
  SearchAdsUseCase(this.repo);

  final BahoSearchRepo repo;

  @override
  Future<Either<Failure, SearchAdsPage>> call(SearchAdsParam param) {
    return repo.searchAds(param);
  }
}
