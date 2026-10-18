import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/image_picker_cropper.dart';
import 'package:heraj_meem/main.dart';
import 'package:extended_image/extended_image.dart';

final orderImagesProvider = StateProvider<List<File>>((ref) => []);

class OrderImagesWidget extends ConsumerWidget {
  const OrderImagesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(orderImagesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.image, size: 18, color: AppColor.primary),
            const Gap(8),
            Text("Prespiction".tr, style: AppFont.font16W600Black),
          ],
        ),
        const Gap(8),
        if (images.isEmpty)
          _buildAddButton(context, ref)
        else
          Column(
            children: [
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length + 1,
                  itemBuilder: (context, index) {
                    if (index == images.length) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildAddButton(context, ref),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildImageItem(context, ref, images[index], index),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        final imagePicker = getIt<ImagePickerService>();
        final pickedFile = await imagePicker.pickImage(crop: false);
        if (pickedFile != null) {
          ref.read(orderImagesProvider.notifier).state = [
            ...ref.read(orderImagesProvider),
            pickedFile,
          ];
        }
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColor.grey1.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.grey1, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: AppColor.grey2),
            const Gap(4),
            Text(
              "Add Image".tr,
              style: AppFont.font12w500Grey2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(BuildContext context, WidgetRef ref, File file, int index) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColor.grey1, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ExtendedImage.file(
              file,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () {
              final currentImages = List<File>.from(ref.read(orderImagesProvider));
              currentImages.removeAt(index);
              ref.read(orderImagesProvider.notifier).state = currentImages;
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColor.danger2,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppColor.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

