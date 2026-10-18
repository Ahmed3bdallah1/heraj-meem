import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/plans/data/models/plans_model.dart';
import 'package:heraj/features/plans/domain/repo/plans_repo.dart';
import 'package:heraj/main.dart';

final fetchPlansProvider = FutureProvider.autoDispose((ref) async {
  final res = await getIt<PlansRepo>().getPlans();
  return res.fold(
    (l) => throw l,
    (r) => r,
  );
});

final fetchMySubscriptionProvider = FutureProvider.autoDispose<MySubscriptionModel>((ref) async {
  final res = await getIt<PlansRepo>().getMySubscription();
  return res.fold(
    (l) => throw l,
    (r) => r,
  );
});
