import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repo/chats_repo.dart';
import '../data_source/chats_data_source.dart';
import '../models/messages_paginated_model.dart';

class ChatsRepoImp implements ChatsRepo {
  final ChatsDataSource dataSource;

  ChatsRepoImp({required this.dataSource});

  @override
  Future<Either<Failure, List<ChatEntity>>> getChats() async {
    try {
      final result = await dataSource.getChats();
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, MessagesPaginatedModel>> getChatMessages(String chatId, {int page = 1, int limit = 50}) async {
    try {
      final result = await dataSource.getChatMessages(chatId, page: page, limit: limit);
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(String chatId, String content, {List<String>? attachments, String? productId}) async {
    try {
      await dataSource.sendMessage(chatId, content, attachments: attachments, productId: productId);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, void>> markChatAsRead(String chatId) async {
    try {
      await dataSource.markChatAsRead(chatId);
      return const Right(null);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }

  @override
  Future<Either<Failure, ChatEntity>> createChat({
    required String userId,
    required String participantId,
    String? productId,
  }) async {
    try {
      final result = await dataSource.createChat(
        userId: userId,
        participantId: participantId,
        productId: productId,
      );
      return Right(result);
    } catch (e) {
      if (e is DioException) {
        return Left(ServerFailure.fromDioError(e));
      }
      return Left(GeneralError(e));
    }
  }
}

