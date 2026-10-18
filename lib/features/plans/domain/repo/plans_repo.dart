import 'package:fpdart/fpdart.dart';
import 'package:heraj_meem/core/errors/failure.dart';
import 'package:heraj_meem/features/plans/data/models/plans_model.dart';

abstract class PlansRepo {
  Future<Either<Failure, List<PlanModel>>> getPlans();
  Future<Either<Failure, MySubscriptionModel>> getMySubscription();
}
