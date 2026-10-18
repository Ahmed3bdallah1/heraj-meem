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

    // Prepare request body
    Map<String, dynamic> requestBody = Map<String, dynamic>.from(data);

    // Remove the File object and add the image path if available
    requestBody.remove('image');
    if (imagePath != null && imagePath.isNotEmpty) {
      requestBody['image'] = imagePath;
    }

    // Remove null and empty values
    requestBody.removeWhere(
        (key, value) => value == null || (value is String && value.isEmpty));

    // Use PUT method for auth/update-profile endpoint
    final res = await apiService.put(
      url: ApiPath.updateProfile,
      requestBody: requestBody,
      returnDataOnly: false,
    );

    return res['message'] ?? 'Profile updated successfully';
  }
}
