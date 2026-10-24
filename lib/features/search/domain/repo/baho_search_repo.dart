import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/features/search/domain/entities/search_ads_page.dart';

abstract class BahoSearchRepo {
  Future<Either<Failure, SearchAdsPage>> searchAds(SearchAdsParam param);
}
