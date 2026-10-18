import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../flutter_firebase_chat.dart';
import '../feature/domain/repo/chats_repo.dart';

class FirestoreDataUploader {
  FirestoreDataUploader() {
    sl<ChatsRepo>().updateUserOnlineStatus(true);
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> uploadUserDataToFirestore({
    required Map<String, dynamic> userData,
    bool createChatRoom = false,
    bool createSampleMessages = false,
  }) async {
    try {
      final userId = userData['id'] ?? userData['_id'] ?? '';
      final userIdString = userId.toString();

      final userDoc = await firestore
          .collection('users')
          .doc(userIdString)
          .get();

      if (!userDoc.exists) {
        final userDocData = {
          'id': userIdString,
          'uuid': userIdString,
          'name': userData['name'] ?? '',
          'email': userData['email'] ?? '',
          'phone': userData['phone'] ?? '',
          'role': userData['role'] ?? 'customer',
          'status': '0',
          'profile_picture': userData['avatar'] ?? '',
          'code': userData['countryCode'] ?? '',
          'is_verified': (userData['isVerified'] ?? false) ? '1' : '0',
          'fcm_token': '',
          'is_online': false,
          'last_seen': FieldValue.serverTimestamp(),
        };

        await firestore
            .collection('users')
            .doc(userIdString)
            .set(userDocData, SetOptions(merge: true));

        if (kDebugMode) {
          print('✅ User uploaded to Firestore: $userIdString');
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ User already exists in Firestore: $userIdString');
        }
      }

      if (createChatRoom) {
        await _createDummyReceiverUser(userIdString);

        if (createSampleMessages) {
          await _createSampleChatRoomAndMessages(userIdString);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading user data: $e');
      }
      rethrow;
    }
  }

  Future<void> _createDummyReceiverUser(String senderUserId) async {
    try {
      final receiverUserId = '$senderUserId#';

      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverUserId)
          .get();

      if (!receiverDoc.exists) {
        final receiverUserData = {
          'id': receiverUserId,
          'uuid': receiverUserId,
          'name': 'Receiver User',
          'email': 'receiver@example.com',
          'phone': '9876543210',
          'role': 'customer',
          'status': '0',
          'profile_picture':
              'https://my-car.backteam.site/dashboard/images/user/user.png',
          'code': '+20',
          'is_verified': '1',
          'fcm_token': '',
          'is_online': false,
          'last_seen': FieldValue.serverTimestamp(),
        };

        await firestore
            .collection('users')
            .doc(receiverUserId)
            .set(receiverUserData, SetOptions(merge: true));

        if (kDebugMode) {
          print('✅ Receiver user created: $receiverUserId');
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ Receiver user already exists: $receiverUserId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating receiver user: $e');
      }
    }
  }

  Future<void> _createSampleChatRoomAndMessages(String senderUserId) async {
    try {
      final receiverUserId = "$senderUserId#";

      List<String> chatIds = [senderUserId, receiverUserId];
      chatIds.sort();
      final chatRoomId = chatIds.join('&');

      final senderDoc = await firestore
          .collection('users')
          .doc(senderUserId)
          .get();
      final receiverDoc = await firestore
          .collection('users')
          .doc(receiverUserId)
          .get();

      if (!senderDoc.exists || !receiverDoc.exists) {
        if (kDebugMode) {
          print('❌ Sender or receiver user not found');
        }
        return;
      }

      final senderData = senderDoc.data()!;
      final receiverData = receiverDoc.data()!;

      final chatRoomDoc = await firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .get();

      if (!chatRoomDoc.exists) {
        await firestore.collection('chat_rooms').doc(chatRoomId).set({
          'senderId': senderUserId,
          'receiverId': receiverUserId,
          'receiverName': receiverData['name'] ?? 'Receiver User',
          'receiverImage':
              receiverData['profile_picture'] ??
              'https://my-car.backteam.site/dashboard/images/user/user.png',
          'lastMessage': 'Hello! This is a sample message.',
          'unreadCount': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (kDebugMode) {
          print('✅ Chat room created: $chatRoomId');
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ Chat room already exists: $chatRoomId');
        }
      }

      final messages = [
        {
          'sender': {
            'id': senderData['id'],
            'uuid': senderData['uuid'],
            'name': senderData['name'],
            'email': senderData['email'],
            'phone': senderData['phone'],
            'role': senderData['role'],
            'status': senderData['status'],
            'profile_picture': senderData['profile_picture'],
            'code': senderData['code'],
            'is_verified': senderData['is_verified'],
            'fcm_token': senderData['fcm_token'],
          },
          'receiver': {
            'id': receiverData['id'],
            'uuid': receiverData['uuid'],
            'name': receiverData['name'],
            'email': receiverData['email'],
            'phone': receiverData['phone'],
            'role': receiverData['role'],
            'status': receiverData['status'],
            'profile_picture': receiverData['profile_picture'],
            'code': receiverData['code'],
            'is_verified': receiverData['is_verified'],
            'fcm_token': receiverData['fcm_token'],
          },
          'message': 'Hello! This is a sample message from sender.',
          'fileUrl': null,
          'messageType': 'text',
          'seen': false,
          'timestamp': Timestamp.now(),
        },
        {
          'sender': {
            'id': receiverData['id'],
            'uuid': receiverData['uuid'],
            'name': receiverData['name'],
            'email': receiverData['email'],
            'phone': receiverData['phone'],
            'role': receiverData['role'],
            'status': receiverData['status'],
            'profile_picture': receiverData['profile_picture'],
            'code': receiverData['code'],
            'is_verified': receiverData['is_verified'],
            'fcm_token': receiverData['fcm_token'],
          },
          'receiver': {
            'id': senderData['id'],
            'uuid': senderData['uuid'],
            'name': senderData['name'],
            'email': senderData['email'],
            'phone': senderData['phone'],
            'role': senderData['role'],
            'status': senderData['status'],
            'profile_picture': senderData['profile_picture'],
            'code': senderData['code'],
            'is_verified': senderData['is_verified'],
            'fcm_token': senderData['fcm_token'],
          },
          'message': 'Hi! This is a reply from receiver.',
          'fileUrl':
              "https://my-car.backteam.site/dashboard/images/user/user.png",
          'messageType': 'image',
          'seen': false,
          'timestamp': Timestamp.now(),
        },
      ];

      final messagesRef = firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages');

      final existingMessages = await messagesRef.limit(1).get();

      if (existingMessages.docs.isEmpty) {
        for (var message in messages) {
          await messagesRef.add(message);
        }

        if (kDebugMode) {
          print('✅ Sample messages created in chat room: $chatRoomId');
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ Messages already exist in chat room: $chatRoomId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating chat room and messages: $e');
      }
    }
  }

  Future<void> uploadUserFromMockResponse({
    required Map<String, dynamic> userData,
    bool createChatRoom = true,
    bool createSampleMessages = true,
  }) async {
    await uploadUserDataToFirestore(
      userData: userData,
      createChatRoom: createChatRoom,
      createSampleMessages: createSampleMessages,
    );
  }

  Future<void> initUserDataIfNotExists({
    required Map<String, dynamic> userData,
    bool createChatRoom = true,
    bool createSampleMessages = true,
  }) async {
    try {
      final userId = userData['id'] ?? userData['_id'] ?? '';
      final userIdString = userId.toString();

      final userDoc = await firestore
          .collection('users')
          .doc(userIdString)
          .get();

      if (!userDoc.exists) {
        if (kDebugMode) {
          print('🔄 Initializing user data in Firestore...');
        }

        await uploadUserDataToFirestore(
          userData: userData,
          createChatRoom: createChatRoom,
          createSampleMessages: createSampleMessages,
        );

        if (kDebugMode) {
          print('✅ User data initialized successfully');
        }
      } else {
        if (kDebugMode) {
          print('ℹ️ User data already exists, skipping initialization');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing user data: $e');
      }
      rethrow;
    }
  }

  static deactivateUserStatus() {
    sl<ChatsRepo>().updateUserOnlineStatus(false);
  }
}
