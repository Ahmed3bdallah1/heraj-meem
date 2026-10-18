import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../../utils/errors/failure.dart';
import '../../domain/repo/chats_repo.dart';
import '../data_source/chats_data_soucre.dart';
import '../models/user_model.dart';
import '../models/massege_model.dart';

class ChatsRepoImpl implements ChatsRepo {
  final ChatsDataSource dataSource;

  ChatsRepoImpl({required this.dataSource});

  @override
  Future<Either<Failure,bool>> sendMessage(UserData? receiver, String message,{String? userId,String? userName, File? file, String? fileUrl, MessageType? messageType}) async {
    try {
      if(receiver == null){
        final receiver = UserData(id: userId ?? "0", name: userName ?? "Unknown", role: "user", isVerified: '1',);
        await dataSource.sendMessage(receiver, message, file: file, fileUrl: fileUrl, messageType: messageType);
      } else {
        await dataSource.sendMessage(receiver, message, file: file, fileUrl: fileUrl, messageType: messageType);
      }
      return Right(true);
    } catch (e) {
      return Left(GeneralError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendImageMessage(UserData? receiver, File imageFile) async {
    try {
      if (receiver == null) {
        return Left(GeneralError("Receiver is required"));
      }
      await dataSource.sendImageMessage(receiver, imageFile);
      return Right(true);
    } catch (e) {
      return Left(GeneralError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendPdfMessage(UserData? receiver, File pdfFile) async {
    try {
      if (receiver == null) {
        return Left(GeneralError("Receiver is required"));
      }
      await dataSource.sendPdfMessage(receiver, pdfFile);
      return Right(true);
    } catch (e) {
      return Left(GeneralError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateUserOnlineStatus(bool isOnline) async {
    try {
      await dataSource.updateUserOnlineStatus(isOnline);
      return Right(true);
    } catch (e) {
      return Left(GeneralError(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, bool>> getUserOnlineStatus(String userId) async* {
    try {
      final stream = dataSource.getUserOnlineStatus(userId);
      yield* stream.map((status) => Right<Failure, bool>(status));
    } catch (e) {
      yield Left(GeneralError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markMessagesAsRead(String receiverId) async {
    try {
      await dataSource.markMessagesAsRead(receiverId);
      return Right(true);
    } catch (e) {
      return Left(GeneralError(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, QuerySnapshot>> getMessages(String receiverId) async* {
    try {
      final stream = dataSource.getMessages(receiverId);
      yield* stream.map((snapshot) => Right<Failure, QuerySnapshot>(snapshot));
    } catch (e) {
      yield Left(GeneralError(e));
    }
  }

  @override
  Stream<Either<Failure, QuerySnapshot>> getChats() async* {
    try {
      final stream = dataSource.getChats();
      yield* stream.map((snapshot) => Right<Failure, QuerySnapshot>(snapshot));
    } catch (e) {
      yield Left(GeneralError(e));
    }
  }
}