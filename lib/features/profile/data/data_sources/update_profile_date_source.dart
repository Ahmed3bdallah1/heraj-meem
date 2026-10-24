import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../../config/api_path.dart';
import '../../../../../core/service/webservice/dio_helper.dart';

abstract class UpdateProfileDataSource {
  Future<String> updateProfile(Map<String, dynamic> data);
}

class UpdateProfileDataSourceImpl extends UpdateProfileDataSource {
  final ApiService apiService;

  UpdateProfileDataSourceImpl(this.apiService);

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(imageFile.path),
      });

      final res = await apiService.post(
        url: ApiPath.uploadImage,
        requestBody: formData,
        returnDataOnly: false,
        receiveTimeout: const Duration(seconds: 60),
        sendTimeOut: const Duration(seconds: 60),
      );

      if (res['data'] != null) {
        return res['data'].toString();
      } else if (res['path'] != null) {
        return res['path'].toString();
      } else if (res['image'] != null) {
        return res['image'].toString();
      }
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  @override
  Future<String> updateProfile(Map<String, dynamic> data) async {
    // Check if there's a new image file to upload
    String? imagePath;
    final imageValue = data['image'];

    if (imageValue != null) {
      if (imageValue is File) {
        // New image file - upload it first to /uploads/images and get the path
        imagePath = await _uploadImage(imageValue);
        if (imagePath == null) {
          throw Exception('Failed to upload image');
        }
      } else if (imageValue is String && imageValue.isNotEmpty) {
        // Existing image path - use it directly
        imagePath = imageValue;
      }
    }

    final requestBody = <String, dynamic>{
      'displayName': data['displayName'] ?? data['name'] ?? '',
      'bio': data['bio']?.toString() ?? '',
    };
    final phone = data['phone'];
    final countryCode = data['countryCode'];
    final email = data['email'];
    if (phone is String && phone.isNotEmpty) requestBody['phone'] = phone;
    if (countryCode is String && countryCode.isNotEmpty) {
      requestBody['countryCode'] = countryCode;
    }
    if (email is String && email.isNotEmpty) requestBody['email'] = email;
    if (imagePath != null && imagePath.isNotEmpty) {
      requestBody['avatarUrl'] = imagePath;
    }

    final res = await apiService.patch(
      url: ApiPath.updateUserMe,
      requestBody: requestBody,
      returnDataOnly: false,
    );

    final body = res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{};
    return body['message']?.toString() ?? 'Profile updated successfully';
  }
}
