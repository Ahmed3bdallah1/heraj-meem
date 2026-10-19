import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/config/api_path.dart';
import 'package:heraj_meem/core/service/webservice/dio_helper.dart';
import 'package:heraj_meem/features/ads/data/models/public_profile_model.dart';
import 'package:heraj_meem/main.dart';

final publicProfileProvider = FutureProvider.autoDispose
    .family<PublicProfileModel, String>((ref, userId) async {
  final data = await getIt<ApiService>().get(
    url: ApiPath.getPublicProfile(userId),
    returnDataOnly: true,
  );
  if (data is! Map) {
    throw Exception('Publisher profile is empty');
  }
  return PublicProfileModel.fromJson(Map<String, dynamic>.from(data));
});
