import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/features/products/domain/repo/product_repo.dart';
import 'package:heraj/features/profile/domain/use_cases/upload_file_use_case.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';
import 'package:image_picker/image_picker.dart';

class AddReviewBottomSheet extends ConsumerStatefulWidget {
  final String productId;

  const AddReviewBottomSheet({super.key, required this.productId});

  @override
  ConsumerState<AddReviewBottomSheet> createState() =>
      _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends ConsumerState<AddReviewBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
  List<String> _uploadedImages = [];
  bool _isFilesUploading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isEmpty) return;

    if (!mounted) return;

    setState(() {
      _isFilesUploading = true;
    });

    try {
      final uploadFileUseCase = getIt<UploadFileUseCase>();
      final List<String> newUploadedPaths = [];

      for (var xFile in images) {
        final file = File(xFile.path);
        final result = await uploadFileUseCase.call(file);
        result.fold(
          (failure) {
            UIHelper.showGlobalSnackBar(
              text: '${"Failed to upload image:".tr} ${xFile.name}',
              color: AppColor.danger,
            );
          },
          (data) {
            if (data.filePath.isNotEmpty) {
              newUploadedPaths.add(data.filePath);
            }
          },
        );
      }

      if (mounted) {
        if (newUploadedPaths.isNotEmpty) {
          setState(() {
            _uploadedImages.addAll(newUploadedPaths);
          });
          UIHelper.showGlobalSnackBar(
            text:
                '${newUploadedPaths.length} ${"image(s) uploaded successfully".tr}',
            color: AppColor.green,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        UIHelper.showGlobalSnackBar(
          text: '${"Error uploading images:".tr} $e',
          color: AppColor.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFilesUploading = false;
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      UIHelper.showGlobalSnackBar(
        text: "Please select a rating".tr,
        color: AppColor.danger,
      );
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      UIHelper.showGlobalSnackBar(
        text: "Please enter a comment".tr,
        color: AppColor.danger,
      );
      return;
    }

    if (_isFilesUploading) {
      UIHelper.showGlobalSnackBar(
        text: "Please wait for images to finish uploading".tr,
        color: AppColor.danger,
      );
      return;
    }

    try {
      UIHelper.showLoadingDialog();
      final res = await getIt<ProductRepo>().addReview(
        widget.productId,
        _rating,
        _commentController.text.trim(),
        _uploadedImages,
      );
      Get.back();

      res.fold(
        (l) => UIHelper.showGlobalSnackBar(
            text: l.message, color: AppColor.danger),
        (r) {
          Get.back();
          UIHelper.showGlobalSnackBar(
              text: "Review added successfully".tr, color: AppColor.green);
        },
      );
    } catch (e) {
      Get.back();
      UIHelper.showGlobalSnackBar(
          text: "Something went wrong".tr, color: AppColor.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // mainAxisSize: MainAxisSize.min,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),
            Text(
              "Add Review".tr,
              style: AppFont.font18W700Black,
            ),
            const Gap(16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: AppColor.primary,
                      size: 32,
                    ),
                  );
                }),
              ),
            ),
            const Gap(16),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write your review here...".tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.grey1),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const Gap(16),
            if (_uploadedImages.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _uploadedImages.length,
                  separatorBuilder: (_, __) => const Gap(8),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _uploadedImages[index],
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const Gap(8),
            if (_isFilesUploading) const LinearProgressIndicator(),
            const Gap(8),
            InkWell(
              onTap: _pickImages,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: AppColor.primary),
                    const Gap(8),
                    Text(
                      "Add Photos".tr,
                      style: AppFont.font14W600Primary,
                    ),
                  ],
                ),
              ),
            ),
            const Gap(24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Submit Review".tr,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Gap(MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 32),
          ],
        ),
      ),
    );
  }
}
