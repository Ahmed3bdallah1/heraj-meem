import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../../utils/errors/failure.dart';
import '../../data/models/user_model.dart';
import '../../data/models/massege_model.dart';

abstract class ChatsRepo {
  Future<Either<Failure,bool>> sendMessage(UserData? receiver, String message,{String? userId,String? userName, File? file, String? fileUrl, MessageType? messageType});
  Future<Either<Failure,bool>> sendImageMessage(UserData? receiver, File imageFile);
  Future<Either<Failure,bool>> sendPdfMessage(UserData? receiver, File pdfFile);
  Future<Either<Failure,bool>> updateUserOnlineStatus(bool isOnline);
  Stream<Either<Failure,bool>> getUserOnlineStatus(String userId);
  Stream<Either<Failure,QuerySnapshot>> getMessages(String receiverId);
  Stream<Either<Failure,QuerySnapshot>> getChats();
  Future<Either<Failure,bool>> markMessagesAsRead(String receiverId);
}