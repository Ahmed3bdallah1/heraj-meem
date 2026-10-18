import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../service_locator.dart';
import '../../data/models/massege_model.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repo/chats_repo.dart';

final fetchChatMessagesProvider = StreamProvider.autoDispose
    .family<List<MessageModel>, String>((ref, id) async* {
      final res = sl<ChatsRepo>().getMessages(id);
      yield* res.map(
        (either) => either.fold(
          (l) => throw l,
          (r) => r.docs
              .map(
                (doc) =>
                    MessageModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
    });

final fetchChatsProvider = StreamProvider.autoDispose<List<ChatEntity>>((
  ref,
) async* {
  if (kDebugMode) {
    print('🔄 [fetchChatsProvider] ========== Provider started ==========');
  }

  final res = sl<ChatsRepo>().getChats();

  if (kDebugMode) {
    print('🔄 [fetchChatsProvider] Got stream from ChatsRepo');
  }

  yield* res.map((either) {
    if (kDebugMode) {
      print('🔄 [fetchChatsProvider] Received either result from stream');
    }

    return either.fold(
      (l) {
        if (kDebugMode) {
          print('❌ [fetchChatsProvider] ========== ERROR ==========');
          print('❌ [fetchChatsProvider] Error: ${l.message}');
          print('❌ [fetchChatsProvider] Error type: ${l.runtimeType}');
          print('❌ [fetchChatsProvider] ============================');
        }
        throw l;
      },
      (r) {
        if (kDebugMode) {
          print('✅ [fetchChatsProvider] ========== SUCCESS ==========');
          print('✅ [fetchChatsProvider] Processing ${r.docs.length} documents');
        }

        final chats = r.docs.map((doc) {
          if (kDebugMode) {
            print('🔄 [fetchChatsProvider] Processing document ${doc.id}');
          }

          final data = doc.data() as Map<String, dynamic>;

          if (kDebugMode) {
            print('🔄 [fetchChatsProvider] Document data:');
            print('   - senderId: ${data['senderId']}');
            print('   - receiverId: ${data['receiverId']}');
            print('   - receiverName: ${data['receiverName']}');
            print('   - lastMessage: ${data['lastMessage']}');
            print('   - unreadCount: ${data['unreadCount']}');
          }

          final unreadCount = data['unreadCount'] ?? 0;

          try {
            final chatEntity = ChatEntity.fromJson({
              ...data,
              'unreadCount': unreadCount,
            });

            if (kDebugMode) {
              print('✅ [fetchChatsProvider] Created ChatEntity:');
              print('   - receiverName: ${chatEntity.receiverName}');
              print('   - lastMessage: ${chatEntity.lastMessage}');
              print('   - unreadCount: ${chatEntity.unreadCount}');
            }

            return chatEntity;
          } catch (e, st) {
            if (kDebugMode) {
              print('❌ [fetchChatsProvider] Error creating ChatEntity:');
              print('   Document ID: ${doc.id}');
              print('   Error: $e');
              print('   Stack: $st');
              print('   Data keys: ${data.keys.toList()}');
            }
            rethrow;
          }
        }).toList();

        if (kDebugMode) {
          print(
            '✅ [fetchChatsProvider] Successfully created ${chats.length} ChatEntity objects',
          );
          print('✅ [fetchChatsProvider] ============================');
        }

        return chats;
      },
    );
  });
});
