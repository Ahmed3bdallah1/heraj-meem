import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../config/api_path.dart';
import '../../../../core/service/local_data_manager.dart';
import '../../../../core/service/localization_service/localization_service.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../../../../main.dart';
import '../../domain/entities/create_ad_request.dart';

abstract class CreateAdDataSource {
  Future<String> uploadMedia(File file);

  Future<String> createAd(CreateAdRequest request);

  Future<void> publishAd(String adId);

  Future<String> updateAd({
    required String adId,
    required CreateAdRequest request,
  });

  Future<void> promoteMedia({
    required String adId,
    required List<String> mediaIds,
  });

  Future<void> deleteMedia(String mediaId);
}

class CreateAdDataSourceImpl implements CreateAdDataSource {
  final ApiService apiClient;

  CreateAdDataSourceImpl({required this.apiClient});

  @override
  Future<String> uploadMedia(File file) async {
    final token = getIt<LocalDataManager>().getToken();
    final response = await apiClient.post(
      url: ApiPath.createMedia,
      returnDataOnly: true,
      receiveTimeout: null,
      sendTimeOut: null,
      header: {
        'Accept-Language':
            getIt<LocaleService>().handleLocaleInMain.languageCode,
        'Accept': Headers.jsonContentType,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      requestBody: FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      }),
    );
    final id = _mediaId(response);
    if (id == null || id.isEmpty) {
      throw Exception('Failed to upload image');
    }
    return id;
  }

  @override
  Future<String> createAd(CreateAdRequest request) async {
    final token = getIt<LocalDataManager>().getToken();
    final form = FormData();
    form.fields.addAll([
      MapEntry('categoryId', request.categoryId),
      MapEntry('cityId', request.cityId),
      MapEntry('title', request.title),
      MapEntry('description', request.description),
      MapEntry('price', request.price.toString()),
      MapEntry('showPhone', request.showPhone.toString()),
      // Backend rejects an empty attributes array until it accepts [].
      if (request.attributes.isNotEmpty)
        MapEntry('attributes', jsonEncode(request.attributes)),
    ]);
    for (final path in request.imagePaths) {
      form.files.add(
        MapEntry('images', await MultipartFile.fromFile(path)),
      );
    }
    final response = await apiClient.post(
      url: ApiPath.createAd,
      returnDataOnly: true,
      receiveTimeout: null,
      sendTimeOut: null,
      header: {
        'Accept-Language':
            getIt<LocaleService>().handleLocaleInMain.languageCode,
        'Accept': Headers.jsonContentType,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      requestBody: form,
    );
    return _adId(response);
  }

  @override
  Future<void> publishAd(String adId) {
    return apiClient.post(url: ApiPath.publishAd(adId));
  }

  @override
  Future<String> updateAd({
    required String adId,
    required CreateAdRequest request,
  }) async {
    final token = getIt<LocalDataManager>().getToken();
    final header = {
      'Accept-Language': getIt<LocaleService>().handleLocaleInMain.languageCode,
      'Accept': Headers.jsonContentType,
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final localImages =
        request.imagePaths.where((path) => !path.startsWith('http')).toList();
    final dynamic body;
    if (localImages.isEmpty) {
      body = {
        'categoryId': request.categoryId,
        'cityId': request.cityId,
        'title': request.title,
        'description': request.description,
        'price': request.price,
        'showPhone': request.showPhone,
        // Backend rejects an empty attributes array until it accepts [].
        if (request.attributes.isNotEmpty) 'attributes': request.attributes,
      };
    } else {
      final form = FormData();
      form.fields.addAll([
        MapEntry('categoryId', request.categoryId),
        MapEntry('cityId', request.cityId),
        MapEntry('title', request.title),
        MapEntry('description', request.description),
        MapEntry('price', request.price.toString()),
        MapEntry('showPhone', request.showPhone.toString()),
        // Backend rejects an empty attributes array until it accepts [].
        if (request.attributes.isNotEmpty)
          MapEntry('attributes', jsonEncode(request.attributes)),
      ]);
      for (final path in localImages) {
        form.files.add(MapEntry('images', await MultipartFile.fromFile(path)));
      }
      body = form;
    }
    final response = await apiClient.patch(
      url: ApiPath.getAd(adId),
      returnDataOnly: true,
      receiveTimeout: null,
      sendTimeOut: null,
      header: localImages.isEmpty ? null : header,
      requestBody: body,
    );
    final id = _adId(response);
    return id.isEmpty ? adId : id;
  }

  @override
  Future<void> promoteMedia({
    required String adId,
    required List<String> mediaIds,
  }) async {
    await apiClient.post(
      url: ApiPath.promoteAdMedia(adId),
      requestBody: {'mediaIds': mediaIds},
    );
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    await apiClient.delete(url: ApiPath.deleteMedia(mediaId));
  }
}

String? _mediaId(dynamic data) {
  if (data is Map) {
    for (final key in ['id', 'mediaId', '_id']) {
      final value = data[key]?.toString() ?? '';
      if (value.isNotEmpty && !value.startsWith('http') && !value.startsWith('/')) {
        return value;
      }
    }
    for (final key in ['images', 'media', 'items']) {
      final nested = _mediaId(data[key]);
      if (nested != null) return nested;
    }
  }
  if (data is List && data.isNotEmpty) return _mediaId(data.first);
  if (data is String &&
      data.isNotEmpty &&
      !data.startsWith('http') &&
      !data.contains('/')) {
    return data;
  }
  return null;
}

String _adId(dynamic data) {
  if (data is Map) {
    final id = data['id'] ?? data['adId'];
    if (id != null && id.toString().isNotEmpty) return id.toString();
    if (data['ad'] is Map) return _adId(data['ad']);
  }
  return '';
}
