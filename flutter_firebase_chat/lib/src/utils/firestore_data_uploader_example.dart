import 'firestore_data_uploader.dart';

/// Example usage of FirestoreDataUploader
///
/// This file demonstrates how to upload user data from mock_login_response
/// to Firestore database with chat rooms and messages.
class FirestoreDataUploaderExample {
  /// Example: Initialize user data if it doesn't exist (Recommended for app init)
  ///
  /// This method checks if the user exists in Firestore and only uploads
  /// if it doesn't exist. Perfect for calling during app initialization.
  static Future<void> initUserDataIfNotExists() async {
    final uploader = FirestoreDataUploader();

    // User data from mock_login_response.dart (lines 12-23)
    final userData = {
      "_id": "693c7ce4c814841fde775f31",
      "id": "693c7ce4c814841fde775f31",
      "phone": "1234567890",
      "countryCode": "+20",
      "role": "customer",
      "name": "",
      "email": "",
      "avatar": "",
      "isVerified": true,
      "isProfileComplete": false,
    };

    // This will only upload if user doesn't exist in Firestore
    await uploader.initUserDataIfNotExists(
      userData: userData,
      createChatRoom: true,
      createSampleMessages: true,
    );
  }

  static Future<void> uploadMockUserData() async {
    final uploader = FirestoreDataUploader();

    final userData = {
      "_id": "693c7ce4c814841fde775f31",
      "id": "693c7ce4c814841fde775f31",
      "phone": "1234567890",
      "countryCode": "+20",
      "role": "customer",
      "name": "",
      "email": "",
      "avatar": "",
      "isVerified": true,
      "isProfileComplete": false,
    };

    await uploader.uploadUserFromMockResponse(
      userData: userData,
      createChatRoom: true,
      createSampleMessages: true,
    );
  }

  static Future<void> uploadUserOnly() async {
    final uploader = FirestoreDataUploader();

    final userData = {
      "_id": "693c7ce4c814841fde775f31",
      "id": "693c7ce4c814841fde775f31",
      "phone": "1234567890",
      "countryCode": "+20",
      "role": "customer",
      "name": "John Doe",
      "email": "john@example.com",
      "avatar": "",
      "isVerified": true,
      "isProfileComplete": false,
    };

    // Upload only user data, no chat room or messages
    await uploader.uploadUserFromMockResponse(
      userData: userData,
      createChatRoom: false,
      createSampleMessages: false,
    );
  }
}
