import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/flutter_firebase_chat.dart';
import '../../../utils/local_service/local_data_manager.dart';
import '../../../utils/file_upload_service.dart';
import '../models/massege_model.dart';
import '../models/user_model.dart';

abstract class ChatsDataSource {
  Future<void> sendMessage(
    UserData receiver,
    String message, {
    File? file,
    String? fileUrl,
    MessageType? messageType,
  });

  Future<void> sendImageMessage(UserData receiver, File imageFile);

  Future<void> sendPdfMessage(UserData receiver, File pdfFile);

  Future<void> updateUserOnlineStatus(bool isOnline);

  Stream<bool> getUserOnlineStatus(String userId);

  Stream<QuerySnapshot> getMessages(String receiverId);

  Stream<QuerySnapshot> getChats();

  Future<void> markMessagesAsRead(String receiverId);
}

class ChatServices extends ChangeNotifier
    with FileUploadService
    implements ChatsDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createChatRoomIfNotExists(
    String chatRoomId,
    UserData receiver,
  ) async {
    final UserData? currentUser =
        dataManager.getUser() ?? ChatServiceInit().userModel;
    final docRef = firestore.collection("chat_rooms").doc(chatRoomId);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        "senderId": currentUser?.id.toString() ?? "0",
        "receiverId": receiver.id.toString(),
        "receiverImage": receiver.profilePicture ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Future<void> sendMessage(
    UserData receiver,
    String message, {
    File? file,
    String? fileUrl,
    MessageType? messageType,
  }) async {
    final UserData? currentUser =
        dataManager.getUser() ?? ChatServiceInit().userModel;
    final Timestamp timestamp = Timestamp.now();

    String? finalFileUrl = fileUrl;
    MessageType finalMessageType = messageType ?? MessageType.text;

    if (file != null && finalFileUrl == null) {
      try {
        finalFileUrl = await uploadFile(
          file,
          currentUser?.id.toString() ?? "0",
          receiver.id.toString(),
        );
        if (file.path.toLowerCase().endsWith('.pdf')) {
          finalMessageType = MessageType.pdf;
        } else {
          finalMessageType = MessageType.image;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error uploading file: $e");
        }
        rethrow;
      }
    }

    List<String> chatId = [
      currentUser?.id.toString() ?? "0",
      receiver.id.toString(),
    ];
    chatId.sort();
    String chatRoomId = chatId.join("&");

    try {
      final chatRoomRef = firestore.collection("chat_rooms").doc(chatRoomId);
      final chatRoomDoc = await chatRoomRef.get();

      int unreadCount = 0;
      if (chatRoomDoc.exists) {
        final data = chatRoomDoc.data();
        unreadCount = data?['unreadCount'] ?? 0;
        if (data?['receiverId'] == receiver.id.toString()) {
          unreadCount++;
        }
      }

      String lastMessageText = message;
      if (finalMessageType == MessageType.image) {
        lastMessageText = "📷 Image";
      } else if (finalMessageType == MessageType.pdf) {
        lastMessageText = "📄 PDF";
      }

      await chatRoomRef.set({
        "senderId": currentUser?.id.toString() ?? "0",
        "receiverId": receiver.id.toString(),
        "receiverName": receiver.name,
        "receiverImage": receiver.profilePicture == ""
            ? "https://my-car.backteam.site/dashboard/images/user/user.png"
            : receiver.profilePicture,
        "lastMessage": lastMessageText,
        "unreadCount": unreadCount,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Send message
      Map<String, dynamic> senderMap = _prepareUserMapForFirestore(
        currentUser!,
      );
      Map<String, dynamic> receiverMap = _prepareUserMapForFirestore(receiver);

      await firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .doc()
          .set({
            "sender": senderMap,
            "receiver": receiverMap,
            "message": message,
            "fileUrl": finalFileUrl,
            "messageType": finalMessageType.name,
            "seen": false,
            "timestamp": timestamp,
          }, SetOptions(merge: true));
    } catch (e) {
      print("Error sending message: $e");
      rethrow;
    }
  }

  @override
  Future<void> sendImageMessage(UserData receiver, File imageFile) async {
    await sendMessage(
      receiver,
      "",
      file: imageFile,
      messageType: MessageType.image,
    );
  }

  @override
  Future<void> sendPdfMessage(UserData receiver, File pdfFile) async {
    await sendMessage(
      receiver,
      "",
      file: pdfFile,
      messageType: MessageType.pdf,
    );
  }

  @override
  Future<void> updateUserOnlineStatus(bool isOnline) async {
    final UserData? currentUser =
        dataManager.getUser() ?? ChatServiceInit().userModel;
    if (currentUser == null) return;

    try {
      await firestore.collection("users").doc(currentUser.id.toString()).set({
        "is_online": isOnline,
        "last_seen": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating online status: $e");
    }
  }

  @override
  Stream<bool> getUserOnlineStatus(String userId) {
    return firestore
        .collection("users")
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['is_online'] ?? false);
  }

  @override
  Future<void> markMessagesAsRead(String receiverId) async {
    final UserData? currentUser =
        dataManager.getUser() ?? ChatServiceInit().userModel;
    if (currentUser == null) return;

    List<String> chatId = [currentUser.id.toString(), receiverId];
    chatId.sort();
    String chatRoomId = chatId.join("&");

    if (kDebugMode) {
      print('🔍 [markMessagesAsRead] Marking messages as read');
      print('🔍 [markMessagesAsRead] receiverId: $receiverId');
      print('🔍 [markMessagesAsRead] chatRoomId: $chatRoomId');
    }

    try {
      final messagesRef = firestore
          .collection("chat_rooms")
          .doc(chatRoomId)
          .collection("messages")
          .where("seen", isEqualTo: false)
          .where("sender.id", isEqualTo: receiverId);

      final messagesSnapshot = await messagesRef.get();
      final batch = firestore.batch();

      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {"seen": true});
      }

      await batch.commit();

      if (kDebugMode) {
        print(
          '✅ [markMessagesAsRead] Marked ${messagesSnapshot.docs.length} messages as read',
        );
      }

      await firestore.collection("chat_rooms").doc(chatRoomId).update({
        "unreadCount": 0,
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("❌ [markMessagesAsRead] Error marking messages as read: $e");
        print("❌ [markMessagesAsRead] Stack trace: $stackTrace");
      } else {
        print("Error marking messages as read: $e");
      }
    }
  }

  Map<String, dynamic> _prepareUserMapForFirestore(UserData user) {
    Map<String, dynamic> toJson() {
      return {
        "id": user.id.toString(),
        "uuid": user.uuid ?? "",
        "name": user.name,
        "email": user.email ?? "",
        "phone": user.phone ?? "",
        "role": user.role ?? "user",
        "status": user.status ?? "0",
        "profile_picture": user.profilePicture ?? "",
        "code": user.code ?? "",
        "is_verified": user.isVerified ?? "0",
        "fcm_token": user.fcmToken ?? "",
      };
    }

    return toJson();
  }

  @override
  Stream<QuerySnapshot> getMessages(String receiverId) {
    final UserData? currentUser =
        dataManager.getUser() ?? ChatServiceInit().userModel;
    List<String> id = [currentUser?.id.toString() ?? "0", receiverId];
    id.sort();
    String chatRoomId = id.join("&");

    final snapshots = firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();

    snapshots.listen((snapshot) async {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final senderData = data["sender"] as Map<String, dynamic>?;
        final senderId = senderData?["id"]?.toString();
        final seen = data["seen"] ?? false;

        if (senderId != null &&
            senderId != currentUser?.id.toString() &&
            seen == false) {
          await doc.reference.update({"seen": true});
        }
      }
      await markMessagesAsRead(receiverId);
    });

    return snapshots;
  }

  @override
  Stream<QuerySnapshot> getChats() {
    final UserData? currentUser =
        dataManager.getUser() ?? ChatServiceInit().userModel;

    if (kDebugMode) {
      print('🔍 [getChats] ========== Starting getChats() ==========');
      print(
        '🔍 [getChats] Current user from dataManager: ${dataManager.getUser()?.id}',
      );
      print(
        '🔍 [getChats] Current user from ChatServiceInit: ${ChatServiceInit().userModel?.id}',
      );
      print('🔍 [getChats] Final current user: ${currentUser?.id}');
      print('🔍 [getChats] Current user name: ${currentUser?.name}');
      print('🔍 [getChats] Current user type: ${currentUser.runtimeType}');
    }

    if (currentUser == null) {
      if (kDebugMode) {
        print('⚠️ [getChats] No current user found, returning empty stream');
      }
      return firestore
          .collection("chat_rooms")
          .where("senderId", isEqualTo: "nonexistent")
          .snapshots();
    }

    final currentUserId = currentUser.id.toString();

    if (kDebugMode) {
      print('🔍 [getChats] Current user ID (original): ${currentUser.id}');
      print('🔍 [getChats] Current user ID (string): $currentUserId');
      print('🔍 [getChats] Current user ID type: ${currentUserId.runtimeType}');
      print('🔍 [getChats] Building query with Filter.or:');
      print('   - senderId == "$currentUserId"');
      print('   - receiverId == "$currentUserId"');
    }

    final query = firestore
        .collection("chat_rooms")
        .where(
          Filter.or(
            Filter("senderId", isEqualTo: currentUserId),
            Filter("receiverId", isEqualTo: currentUserId),
          ),
        )
        .orderBy("updatedAt", descending: true);

    if (kDebugMode) {
      print('🔍 [getChats] Query created successfully');
      print('🔍 [getChats] Listening to snapshots...');
    }

    return query
        .snapshots()
        .map((snapshot) {
          if (kDebugMode) {
            print('📦 [getChats] ========== Snapshot received ==========');
            print(
              '📦 [getChats] Snapshot size: ${snapshot.docs.length} documents',
            );
            print('📦 [getChats] Snapshot metadata: ${snapshot.metadata}');
            print(
              '📦 [getChats] Snapshot has pending writes: ${snapshot.metadata.hasPendingWrites}',
            );

            if (snapshot.docs.isEmpty) {
              print(
                '⚠️ [getChats] No documents found in chat_rooms collection',
              );
              print('⚠️ [getChats] This could mean:');
              print('   1. No chat rooms exist for this user');
              print('   2. The user ID format doesn\'t match stored data');
              print('   3. The query filter is not matching any documents');
            } else {
              print('✅ [getChats] Found ${snapshot.docs.length} chat room(s)');
              for (var i = 0; i < snapshot.docs.length; i++) {
                final doc = snapshot.docs[i];
                final data = doc.data();
                print('📦 [getChats] Document #${i + 1} (ID: ${doc.id}):');
                print(
                  '   - senderId: ${data['senderId']} (type: ${data['senderId']?.runtimeType})',
                );
                print(
                  '   - receiverId: ${data['receiverId']} (type: ${data['receiverId']?.runtimeType})',
                );
                print('   - receiverName: ${data['receiverName']}');
                print('   - lastMessage: ${data['lastMessage']}');
                print('   - unreadCount: ${data['unreadCount']}');
                print('   - updatedAt: ${data['updatedAt']}');
                print('   - createdAt: ${data['createdAt']}');

                final senderId = data['senderId']?.toString();
                final receiverId = data['receiverId']?.toString();
                final matchesSender = senderId == currentUserId;
                final matchesReceiver = receiverId == currentUserId;
                print('   - Matches senderId? $matchesSender');
                print('   - Matches receiverId? $matchesReceiver');
                if (!matchesSender && !matchesReceiver) {
                  print(
                    '   ⚠️ WARNING: This document doesn\'t match current user!',
                  );
                }
              }
            }
            print('📦 [getChats] ========================================');
          }
          return snapshot;
        })
        .handleError((error, stackTrace) {
          if (kDebugMode) {
            print('❌ [getChats] ========== ERROR in stream ==========');
            print('❌ [getChats] Error: $error');
            print('❌ [getChats] Error type: ${error.runtimeType}');
            print('❌ [getChats] Stack trace: $stackTrace');

            if (error is FirebaseException) {
              print('❌ [getChats] Firebase error code: ${error.code}');
              print('❌ [getChats] Firebase error message: ${error.message}');
              if (error.code == 'failed-precondition') {
                print(
                  '❌ [getChats] This usually means a composite index is required!',
                );
                print('❌ [getChats] Create an index in Firestore Console for:');
                print('   Collection: chat_rooms');
                print(
                  '   Fields: senderId (Ascending), receiverId (Ascending), updatedAt (Descending)',
                );
              }
            }
            print('❌ [getChats] ========================================');
          }
          throw error;
        });
  }
}
