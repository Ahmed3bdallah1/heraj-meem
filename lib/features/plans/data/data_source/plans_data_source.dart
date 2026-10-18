import 'package:heraj/config/api_path.dart';
import 'package:heraj/core/service/webservice/dio_helper.dart';
import 'package:heraj/features/plans/data/models/plans_model.dart';

abstract class PlansDataSource {
  Future<List<PlanModel>> getPlans();
  Future<MySubscriptionModel> getMySubscription();
}

class PlansDataSourceImp extends PlansDataSource {
  final ApiService apiService;

  PlansDataSourceImp({required this.apiService});

  @override
  Future<List<PlanModel>> getPlans() async {
    final res = await apiService.get(
      url: ApiPath.getPlans,
      returnDataOnly: true
    );
    final plans = res["plans"] as List;
    return plans.map((e) => PlanModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<MySubscriptionModel> getMySubscription() async {
    final res = await apiService.get<Map<String, dynamic>>(
      url: ApiPath.getMySubscription,
      returnDataOnly: true,
    );
    return MySubscriptionModel.fromJson(res as Map<String, dynamic>);
  }
}