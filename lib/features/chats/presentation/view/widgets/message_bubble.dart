import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import '../../../domain/entities/message_entity.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
          minWidth: MediaQuery.of(context).size.width * 0.2,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColor.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isMe ? const Radius.circular(4) : null,
                  bottomLeft: !isMe ? const Radius.circular(4) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.attachments.isNotEmpty)
                    _buildImagesGrid(message.attachments, isMe),
                  if (message.content.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        top: message.attachments.isNotEmpty ? 8 : 0,
                      ),
                      child: Text(
                        message.content,
                        style: AppFont.font14W500Black.copyWith(
                          color: isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  if (showTime) ...[
                    const Gap(4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(message.createdAt, showJustNow: showTime),
                          style: AppFont.font12w500Grey2.copyWith(
                            color: isMe
                                ? Colors.white.withOpacity(0.7)
                                : Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesGrid(List<String> attachments, bool isMe) {
    if (attachments.length == 1) {
      // Single image - show large
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            attachments.first,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image),
              );
            },
          ),
        ),
      );
    }

    // Multiple images - show in grid
    final crossAxisCount = attachments.length == 2 ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: attachments.length > 9 ? 9 : attachments.length,
      itemBuilder: (context, index) {
        final url = attachments[index];
        final isLastItem = index == 8 && attachments.length > 9;
        
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 20),
                  );
                },
              ),
            ),
            if (isLastItem)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '+${attachments.length - 9}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dateTime, {bool showJustNow = true}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1 && showJustNow) {
      return 'Just now'.tr;
    } else if (difference.inMinutes < 1 && !showJustNow) {
      final period = dateTime.hour >= 12 ? 'PM'.tr : 'AM'.tr;
      final displayHour = dateTime.hour > 12
          ? dateTime.hour - 12
          : (dateTime.hour == 0 ? 12 : dateTime.hour);
      return '${displayHour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${"mins ago".tr}';
    } else if (difference.inDays < 1) {
      final period = dateTime.hour >= 12 ? 'PM'.tr : 'AM'.tr;
      final displayHour = dateTime.hour > 12
          ? dateTime.hour - 12
          : (dateTime.hour == 0 ? 12 : dateTime.hour);
      return '${displayHour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday'.tr;
    } else {
      final period = dateTime.hour >= 12 ? 'PM'.tr : 'AM'.tr;
      final displayHour = dateTime.hour > 12
          ? dateTime.hour - 12
          : (dateTime.hour == 0 ? 12 : dateTime.hour);
      return '${DateFormat('MMM d').format(dateTime)}, ${displayHour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
    }
  }
}
