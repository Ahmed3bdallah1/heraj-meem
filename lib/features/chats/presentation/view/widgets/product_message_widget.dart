import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/ui/shared_widgets/price_widget.dart';
import '../../../domain/entities/message_entity.dart';
import 'package:heraj/features/products/presentation/view/product_details_screen.dart';
import 'package:intl/intl.dart';

class ProductMessageWidget extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final bool showTime;

  const ProductMessageWidget({
    super.key,
    required this.message,
    required this.isMe,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    final product = message.productId;
    if (product == null) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
                  if (message.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        message.content,
                        style: AppFont.font14W500Black.copyWith(
                          color: isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => ProductDetailsScreen(productId: product.id));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (product.images.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.images.first,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image),
                                  );
                                },
                              ),
                            ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  style: AppFont.font14W600Black.copyWith(
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Gap(4),
                                PriceWidget(
                                  price: product.price.toStringAsFixed(2),
                                  style: AppFont.font16W700Primary,
                                  textColor: AppColor.primary,
                                  currencySize: 18,
                                ),
                                const Gap(4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.open_in_new,
                                      size: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    const Gap(4),
                                    Text(
                                      'View Product'.tr,
                                      style: AppFont.font12w500Grey2.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showTime) ...[
                    const Gap(4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _formatTime(message.createdAt, showJustNow: showTime),
                        style: AppFont.font12w500Grey2.copyWith(
                          color: isMe 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
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

  String _formatTime(DateTime dateTime, {bool showJustNow = true}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1 && showJustNow) {
      return 'Just now'.tr;
    } else if (difference.inMinutes < 1 && !showJustNow) {
      final period = dateTime.hour >= 12 ? 'PM'.tr : 'AM'.tr;
      final displayHour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      return '${displayHour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${"mins ago".tr}';
    } else if (difference.inDays < 1) {
      final period = dateTime.hour >= 12 ? 'PM'.tr : 'AM'.tr;
      final displayHour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      return '${displayHour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday'.tr;
    } else {
      final period = dateTime.hour >= 12 ? 'PM'.tr : 'AM'.tr;
      final displayHour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      return '${DateFormat('MMM d').format(dateTime)}, ${displayHour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
    }
  }
}

