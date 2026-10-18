import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:heraj_meem/config/api_path.dart';
import 'package:heraj_meem/core/service/local_data_manager.dart';
import 'package:heraj_meem/core/service/localization_service/localization_service.dart';
import 'package:heraj_meem/core/service/webservice/dio_helper.dart';
import 'package:heraj_meem/features/home/data/models/home_data_model.dart';

abstract class HomeDataSource {
  Future<HomeDataModel> getHomeData();
}

Future<HomeDataModel> _fetchAndParseHomeDataInIsolate(
  Map<String, dynamic> params,
) async {
  final baseUrl = params['baseUrl'] as String;
  final endpoint = params['endpoint'] as String;
  final token = params['token'] as String?;
  final language = params['language'] as String;
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Accept-Language': language,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ),
  );

  try {
    final response = await dio.get(endpoint);
    logger.w(response.data);
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      final jsonData = response.data['data'] as Map<String, dynamic>;
      final parsedData = _parseHomeDataJson(jsonData);

      final homeData = HomeDataModel.fromJson(parsedData);

      return homeData;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  } catch (e) {
    rethrow;
  }
}

Map<String, dynamic> _parseHomeDataJson(Map<String, dynamic> json) {
  final stories = (json['stories'] as List?)
          ?.map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            }
            return null;
          })
          .where((item) => item != null)
          .toList() ??
      [];

  final slidersList = <Map<String, dynamic>>[];
  final slidersRaw = json['sliders'] as List?;
  if (slidersRaw != null) {
    for (final item in slidersRaw) {
      if (item is Map<String, dynamic>) {
        final isActive = item['isActive'] ?? true;
        if (isActive) {
          slidersList.add(item);
        }
      }
    }
  }
  slidersList.sort(
      (a, b) => (a['order'] as int? ?? 0).compareTo(b['order'] as int? ?? 0));

  final categories = (json['categories'] as List?)?.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        return {};
      }).toList() ??
      [];

  List<Map<String, dynamic>> parseProducts(List? productsList) {
    return productsList?.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }
          return <String, dynamic>{};
        }).toList() ??
        [];
  }

  final realEstate = parseProducts(json['realEstate']);
  final latestProducts = parseProducts(json['latestProducts']);
  final hotDeals = parseProducts(json['hotDeals']);
  final adminProducts = parseProducts(json['adminProducts']);

  // Parse stores
  final topStores = (json['topStores'] as List?)?.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        return <String, dynamic>{};
      }).toList() ??
      [];

  return {
    'stories': stories,
    'sliders': slidersList,
    'categories': categories,
    'realEstate': realEstate,
    'latestProducts': latestProducts,
    'hotDeals': hotDeals,
    'adminProducts': adminProducts,
    'topStores': topStores,
  };
}

class HomeDataSourceImp extends HomeDataSource {
  final ApiService apiService;
  final LocalDataManager localDataManager;
  final LocaleService localeService;

  HomeDataSourceImp({
    required this.apiService,
    required this.localDataManager,
    required this.localeService,
  });

  @override
  Future<HomeDataModel> getHomeData() async {
    final token = localDataManager.getToken();
    final language = localeService.handleLocaleInMain.languageCode;
    final params = {
      'baseUrl': ApiPath.baseurl,
      'endpoint': ApiPath.getHomeData,
      'token': token,
      'language': language,
    };

    final parsedData = await compute(_fetchAndParseHomeDataInIsolate, params);

    return parsedData;
  }
}
