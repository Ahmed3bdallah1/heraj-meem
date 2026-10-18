import 'dart:io';
import 'package:heraj/config/api_path.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/core/service/webservice/dio_helper.dart';

class FCMTokenService {
  final ApiService apiService;

  FCMTokenService(this.apiService);

  String get _deviceType {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    }
    return 'android';
  }


  Future<bool> registerFCMToken() async {
    try {
      final token = dataManager.getFCMToken();
      if (token == null || token.isEmpty) {
        print(
            '⚠️ FCM Token is not available. Make sure notification service has initialized and saved the token.');
        return false;
      }

      await apiService.post(
        url: ApiPath.registerFCMToken,
        requestBody: {
          'token': token,
          'device': _deviceType,
        },
        returnDataOnly: false,
      );

      print('✅ FCM Token registered successfully: $token');
      return true;
    } catch (e) {
      print('❌ Error registering FCM token: $e');
      return false;
    }
  }

  Future<bool> removeFCMToken() async {
    try {
      final fcmToken = dataManager.getFCMToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        print('⚠️ No FCM Token to remove');
      }

      await apiService.delete(
        url: ApiPath.removeFCMToken,
        requestBody: {
          'token': fcmToken,
        },
        returnDataOnly: false,
      );

      print('✅ FCM Token removed successfully: $fcmToken');
      return true;
    } catch (e) {
      print('❌ Error removing FCM token: $e');
      return true;
    }
  }
}
