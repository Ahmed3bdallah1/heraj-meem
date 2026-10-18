import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../data/models/loyalty_points_model.dart';
import '../../domain/use_case/loyalty_points_use_case.dart';

final loyaltyPointsProvider = FutureProvider<LoyaltyPointsModel>((ref) async {
  final loyaltyPoints = await getIt<FetchLoyaltyPointsUseCase>().call();
  return loyaltyPoints.fold(
    (l) => throw l,
    (r) => r,
  );
});


