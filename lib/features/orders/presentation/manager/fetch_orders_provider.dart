import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../domain/use_case/fetch_orders_use_case.dart';
import '../../data/models/order_model.dart';

final fetchOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final res = await getIt<FetchOrdersUseCase>().call();
  return res.fold((l) => throw l, (r) => r.data);
});


