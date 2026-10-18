import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../data/models/store_details_model.dart';
import '../../domain/use_case/fetch_stores_use_case.dart';

final fetchStoreDetailsProvider = FutureProvider.autoDispose.family<StoreDetailsModel, String>((ref, vendorId) async {
  final res = await getIt<FetchStoreDetailsUseCase>().call(vendorId);
  return res.fold((l) => throw l, (r) => r);
});