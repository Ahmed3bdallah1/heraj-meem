import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat/src/components/loading_widget.dart';
import 'package:flutter_firebase_chat/src/utils/local_service/local_data_manager.dart';
import 'package:flutter_firebase_chat/src/utils/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../service_locator.dart';
import '../../data/models/massege_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/repo/chats_repo.dart';
import '../managers/chat_providers.dart';

class ChatPage extends ConsumerStatefulWidget {
  final bool? isDisabled;
  final String receiverId;
  final String receiverName;
  final PreferredSizeWidget? customAppBar;
  final UserData receiver;
  final Color? primaryColor;

  const ChatPage({
    super.key,
    this.isDisabled = false,
    required this.receiverId,
    required this.receiverName,
    required this.receiver,
    this.customAppBar,
    this.primaryColor,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<ChatsRepo>().markMessagesAsRead(widget.receiverId);
      sl<ChatsRepo>().updateUserOnlineStatus(true);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    sl<ChatsRepo>().updateUserOnlineStatus(false);
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() => _isUploading = true);
        final file = File(image.path);
        await sl<ChatsRepo>().sendImageMessage(widget.receiver, file);
        setState(() => _isUploading = false);
        ref.invalidate(fetchChatsProvider);
        ref.invalidate(fetchChatMessagesProvider);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      Get.snackbar("Error", "Failed to send image: $e");
    }
  }

  Future<void> _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);
        final file = File(result.files.single.path!);
        await sl<ChatsRepo>().sendPdfMessage(widget.receiver, file);
        setState(() => _isUploading = false);
        ref.invalidate(fetchChatsProvider);
        ref.invalidate(fetchChatMessagesProvider);
      }
    } catch (e) {
      setState(() => _isUploading = false);
      Get.snackbar("Error", "Failed to send PDF: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      await sl<ChatsRepo>().sendMessage(
        widget.receiver,
        message,
        userId: widget.receiverId,
        userName: widget.receiverName,
      );
      ref.invalidate(fetchChatsProvider);
      ref.invalidate(fetchChatMessagesProvider);

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: $e");
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Today".tr;
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return "Yesterday".tr;
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  String? formatLastSeen(Timestamp lastSeen) {
    final now = DateTime.now();
    final lastSeenDate = lastSeen.toDate();
    final difference = now.difference(lastSeenDate);

    if (difference.inMinutes < 1) {
      return "1m";
    } else if (difference.inMinutes < 60) {
      return difference.inMinutes == 1 ? '1m' : '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return difference.inHours == 1 ? '1h' : '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return "1d";
    } else if (difference.inDays < 7) {
      return difference.inDays == 1 ? '1d' : '${difference.inDays}d';
    } else {
      return null;
    }
  }

  Widget _buildMessageBubble(MessageModel message, bool isCurrentUser) {
    final orangeColor = widget.primaryColor ?? const Color(0xffF39200);

    if (message.messageType == MessageType.image.name &&
        message.fileUrl != null) {
      return _buildImageMessage(message, isCurrentUser, orangeColor);
    } else if (message.messageType == MessageType.pdf.name &&
        message.fileUrl != null) {
      return _buildPdfMessage(message, isCurrentUser, orangeColor);
    } else {
      return _buildTextMessage(message, isCurrentUser, orangeColor);
    }
  }

  Widget _buildTextMessage(
    MessageModel message,
    bool isCurrentUser,
    Color orangeColor,
  ) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrentUser ? orangeColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Directionality(
          textDirection: isCurrentUser ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.message,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMessageStatusIcon(message.seen, isCurrentUser),
                  Text(
                    _formatTime(message.timestamp.toDate()),
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageStatusIcon(bool seen, bool isCurrentUser) {
    if (!isCurrentUser) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(
        seen ? Icons.done_all : Icons.done,
        size: 14,
        color: seen ? Colors.white : Colors.white.withAlpha(250),
      ),
    );
  }

  Widget _buildImageMessage(
    MessageModel message,
    bool isCurrentUser,
    Color orangeColor,
  ) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.black,
                        iconTheme: const IconThemeData(color: Colors.white),
                      ),
                      body: PhotoView(
                        imageProvider: NetworkImage(message.fileUrl!),
                      ),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.fileUrl!,
                  width: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            if (message.message.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isCurrentUser ? orangeColor : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp.toDate()),
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfMessage(
    MessageModel message,
    bool isCurrentUser,
    Color orangeColor,
  ) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser ? orangeColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "PDF Document",
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (message.message.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.message,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                if (message.fileUrl != null) {
                  final uri = Uri.parse(message.fileUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? Colors.white.withAlpha(50)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.download,
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Open PDF".tr,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp.toDate()),
              style: TextStyle(
                color: isCurrentUser
                    ? Colors.white.withAlpha(175)
                    : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orangeColor = widget.primaryColor ?? const Color(0xffF39200);
    final currentUser = dataManager.getUser()!;
    bool isCurrentUser(message) => message.sender.id == currentUser.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          widget.customAppBar ??
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            leadingWidth: 30,
            title: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.receiverId)
                  .snapshots(),
              builder: (context, snapshot) {
                bool? isOnline;
                Timestamp lastSeen = Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10)));
                if (snapshot.hasData && snapshot.data != null) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  isOnline = data?['is_online'] as bool? ?? false;
                  lastSeen =
                      data?['last_seen'] as Timestamp? ?? Timestamp.now();
                } else {
                  isOnline = widget.receiver.isOnline ?? false;
                }

                return Row(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            widget.receiver.profilePicture != "" ||
                                    widget.receiver.profilePicture != null
                                ? widget.receiver.profilePicture!
                                : "https://dovercourt.org/610-6104451_image-placeholder-png-user-profile-placeholder-image-png/",
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          )
                        else if (formatLastSeen(lastSeen!) != null)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withAlpha(100),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  formatLastSeen(lastSeen)!,
                                  style: TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.receiverName,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                          isOnline == true ? "online" : "offline",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      body: Column(
        children: [
          Expanded(
            child: ref
                .watch(fetchChatMessagesProvider(widget.receiverId))
                .customWhen(
                  ref: ref,
                  refreshable: fetchChatMessagesProvider(
                    widget.receiverId,
                  ).future,
                  skipLoadingOnRefresh: true,
                  skipLoadingOnReload: true,
                  loading: () => const Center(child: LoadingWidget()),
                  data: (conversation) {
                    if (conversation.isEmpty) {
                      return const Center(child: Text("No messages yet"));
                    }

                    Map<String, List<MessageModel>> groupedMessages = {};
                    for (var message in conversation) {
                      final dateKey = _formatDate(message.timestamp.toDate());
                      if (!groupedMessages.containsKey(dateKey)) {
                        groupedMessages[dateKey] = [];
                      }
                      groupedMessages[dateKey]!.add(message);
                    }

                    List<Widget> messageWidgets = [];
                    for (var dateKey in groupedMessages.keys) {
                      messageWidgets.add(
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dateKey,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                      );

                      for (var message in groupedMessages[dateKey]!) {
                        messageWidgets.add(
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isCurrentUser(message))
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 0,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      message.sender.profilePicture ?? "",
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300],
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: const Icon(
                                                Icons.person,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: _buildMessageBubble(
                                  message,
                                  isCurrentUser(message),
                                ),
                              ),
                              if (isCurrentUser(message))
                                const SizedBox(width: 4),
                            ],
                          ),
                        );
                      }
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: messageWidgets.length,
                      itemBuilder: (context, index) {
                        return messageWidgets[messageWidgets.length -
                            1 -
                            index];
                      },
                    );
                  },
                ),
          ),
          // Input Field
          if (widget.isDisabled != true)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.top,
                      controller: _messageController,
                      decoration: InputDecoration(
                        fillColor: Colors.grey[200],
                        prefix: Icon(Icons.camera_alt, color: orangeColor),
                        filled: true,
                        prefixIconConstraints: BoxConstraints(
                          maxHeight: 50,
                          minHeight: 30,
                        ),
                        hintText: "type message".tr,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.mic, color: orangeColor),
                    onPressed: _isUploading
                        ? null
                        : () {
                            Get.snackbar("Info", "Voice recording coming soon");
                          },
                  ),
                ],
              ),
            ),
          if (_isUploading)
            Container(
              padding: const EdgeInsets.all(8),
              color: orangeColor.withAlpha(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(orangeColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Uploading...",
                    style: TextStyle(color: orangeColor, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
