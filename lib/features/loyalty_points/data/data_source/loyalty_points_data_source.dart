import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/loyalty_points_model.dart';

abstract class LoyaltyPointsDataSource {
  Future<LoyaltyPointsModel> getLoyaltyPoints();
}

class LoyaltyPointsDataSourceImpl implements LoyaltyPointsDataSource {
  final ApiService apiService;

  LoyaltyPointsDataSourceImpl({required this.apiService});

  @override
  Future<LoyaltyPointsModel> getLoyaltyPoints() async {
    try {
      final response = await apiService.get(
        url: ApiPath.loyaltyPoints,
        returnDataOnly: true,
      );
      return LoyaltyPointsModel.fromJson(response);
    } catch (e) {
      return _getDummyLoyaltyPoints();
    }
  }

  LoyaltyPointsModel _getDummyLoyaltyPoints() {
    final now = DateTime.now();
    
    return LoyaltyPointsModel(
      balance: 1250,
      history: [
        LoyaltyPointsHistoryItem(
          id: 1,
          points: 500,
          type: 'purchase',
          description: 'Points earned from order #12345',
          createdAt: now.subtract(Duration(days: 1)).toIso8601String(),
          orderId: '12345',
        ),
        LoyaltyPointsHistoryItem(
          id: 2,
          points: -200,
          type: 'redeemed',
          description: 'Points redeemed for discount',
          createdAt: now.subtract(Duration(days: 3)).toIso8601String(),
        ),
        LoyaltyPointsHistoryItem(
          id: 3,
          points: 300,
          type: 'purchase',
          description: 'Points earned from order #12340',
          createdAt: now.subtract(Duration(days: 5)).toIso8601String(),
          orderId: '12340',
        ),
        LoyaltyPointsHistoryItem(
          id: 4,
          points: 150,
          type: 'bonus',
          description: 'Welcome bonus points',
          createdAt: now.subtract(Duration(days: 7)).toIso8601String(),
        ),
        LoyaltyPointsHistoryItem(
          id: 5,
          points: -100,
          type: 'redeemed',
          description: 'Points redeemed for gift card',
          createdAt: now.subtract(Duration(days: 10)).toIso8601String(),
        ),
        LoyaltyPointsHistoryItem(
          id: 6,
          points: 400,
          type: 'purchase',
          description: 'Points earned from order #12330',
          createdAt: now.subtract(Duration(days: 12)).toIso8601String(),
          orderId: '12330',
        ),
        LoyaltyPointsHistoryItem(
          id: 7,
          points: 200,
          type: 'referral',
          description: 'Referral bonus - Friend signup',
          createdAt: now.subtract(Duration(days: 15)).toIso8601String(),
        ),
        LoyaltyPointsHistoryItem(
          id: 8,
          points: -50,
          type: 'redeemed',
          description: 'Points redeemed for free shipping',
          createdAt: now.subtract(Duration(days: 18)).toIso8601String(),
        ),
        LoyaltyPointsHistoryItem(
          id: 9,
          points: 250,
          type: 'purchase',
          description: 'Points earned from order #12320',
          createdAt: now.subtract(Duration(days: 20)).toIso8601String(),
          orderId: '12320',
        ),
        LoyaltyPointsHistoryItem(
          id: 10,
          points: 100,
          type: 'review',
          description: 'Points earned for product review',
          createdAt: now.subtract(Duration(days: 25)).toIso8601String(),
        ),
      ],
    );
  }
}

