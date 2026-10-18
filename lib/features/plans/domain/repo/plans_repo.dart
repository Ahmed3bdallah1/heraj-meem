import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/plans/data/models/plans_model.dart';

abstract class PlansRepo {
  Future<Either<Failure, List<PlanModel>>> getPlans();
  Future<Either<Failure, MySubscriptionModel>> getMySubscription();
}
