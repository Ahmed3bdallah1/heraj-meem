import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/features/location/data/models/city_model.dart';
import 'package:heraj_meem/features/location/data/models/district_model.dart';
import 'package:heraj_meem/features/location/domain/use_case/fetch_cities_use_case.dart';
import 'package:heraj_meem/features/location/domain/use_case/fetch_districts_use_case.dart';
import 'package:heraj_meem/features/location/domain/use_case/fetch_neighborhoods_use_case.dart';
import 'package:heraj_meem/main.dart';

final fetchCitiesProvider =
    FutureProvider.autoDispose<CitiesResponse>((ref) async {
  final useCase = getIt<FetchCitiesUseCase>();
  final result = await useCase.call();
  return result.fold((l) => throw l, (r) => r);
});

final fetchDistrictsProvider = FutureProvider.autoDispose
    .family<DistrictsResponse, String>((ref, cityCode) async {
  final useCase = getIt<FetchDistrictsUseCase>();
  final result = await useCase.call(FetchDistrictsParams(cityCode));
  return result.fold((l) => throw l, (r) => r);
});

final fetchNeighborhoodsProvider = FutureProvider.autoDispose
    .family<NeighborhoodsResponse, FetchNeighborhoodsParams>((ref, params) async {
  final useCase = getIt<FetchNeighborhoodsUseCase>();
  final result = await useCase.call(params);
  return result.fold((l) => throw l, (r) => r);
});

