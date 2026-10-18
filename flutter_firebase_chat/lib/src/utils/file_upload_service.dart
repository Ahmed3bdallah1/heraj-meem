import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

mixin FileUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String> uploadFile(File file, String userId, String receiverId) async {
    try {
      final String fileName = _uuid.v4();
      final String extension = file.path.split('.').last;
      final String fileType = _getFileType(extension);

      final String path = 'chat_files/$userId/$receiverId/$fileName.$extension';
      final Reference ref = _storage.ref().child(path);

      final UploadTask uploadTask = ref.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<String> uploadImage(
    File imageFile,
    String userId,
    String receiverId,
  ) async {
    return uploadFile(imageFile, userId, receiverId);
  }

  Future<String> uploadPdf(
    File pdfFile,
    String userId,
    String receiverId,
  ) async {
    return uploadFile(pdfFile, userId, receiverId);
  }

  String _getFileType(String extension) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    if (imageExtensions.contains(extension.toLowerCase())) {
      return 'image';
    } else if (extension.toLowerCase() == 'pdf') {
      return 'pdf';
    }
    return 'file';
  }

  Future<void> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }
}
