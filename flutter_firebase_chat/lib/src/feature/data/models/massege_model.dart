import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_firebase_chat/src/feature/data/models/user_model.dart';

enum MessageType { text, image, pdf }

class MessageModel {
  final UserData sender;
  final UserData receiver;
  final String message;
  final bool seen;
  final File? file;
  final String? fileUrl;
  final String messageType;
  final Timestamp timestamp;

  MessageModel({
    required this.sender,
    required this.receiver,
    required this.message,
    required this.timestamp,
    required this.seen,
    this.file,
    this.fileUrl,
    this.messageType = "text",
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    String type = MessageType.text.name;
    if (map['fileUrl'] != null) {
      final url = map['fileUrl'] as String;
      if (url.contains('.pdf')) {
        type = MessageType.pdf.name;
      } else if (url.contains('.jpg') ||
          url.contains('.jpeg') ||
          url.contains('.png') ||
          url.contains('.gif')) {
        type = MessageType.image.name;
      }
    }

    return MessageModel(
      sender: UserData.fromJson(map['sender']),
      receiver: UserData.fromJson(map['receiver']),
      message: map['message'] ?? '',
      seen: map['seen'] ?? false,
      timestamp: map['timestamp'],
      file: map['file'] != null ? File(map['file']) : null,
      fileUrl: map['fileUrl'],
      messageType: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sender": sender.toJson(),
      "receiver": receiver.toJson(),
      "message": message,
      "fileUrl": fileUrl,
      "messageType": messageType.toString(),
      "seen": seen,
      "timestamp": timestamp,
    };
  }
}
