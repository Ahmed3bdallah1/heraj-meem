import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/config/api_path.dart';
import 'package:heraj_meem/core/service/webservice/dio_helper.dart';
import 'package:heraj_meem/features/ads/data/models/seller_reviews.dart';
import 'package:heraj_meem/main.dart';

final sellerReviewsProvider = FutureProvider.autoDispose
    .family<SellerReviews, String>((ref, userId) async {
  final data = await getIt<ApiService>().get(
    url: ApiPath.getSellerReviews(userId),
    returnDataOnly: true,
  );
  return SellerReviews.fromData(data);
});
