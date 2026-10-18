import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/home/data/models/home_data_model.dart';
import 'package:heraj/features/home/domain/use_case/fetch_home_data_use_case.dart';
import '../../../../../main.dart';

final fetchHomeDataProvider = FutureProvider<HomeDataModel>((ref) async {
  final res = await getIt<FetchHomeDataUseCase>().call();
  return res.fold((l) => throw l, (r) => r);
});
