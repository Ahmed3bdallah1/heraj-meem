import 'dart:io';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_color.dart';

abstract class ImagePickerService {
  Future<File?> pickImage(
      {bool crop = false, ImageSource source = ImageSource.gallery});

  Future<File?> cropImage(String path);
}

class ImagePickerServiceImpl extends ImagePickerService {
  @override
  Future<File?> pickImage(
      {bool crop = false, ImageSource source = ImageSource.gallery}) async {
    final pickedImage = await ImagePicker().pickImage(
      source: source,
      // imageQuality: 50,
      // maxWidth: 800,
    );
    if (pickedImage == null) {
      return null;
    }
    if (crop) {
      return cropImage(pickedImage.path);
    } else {
      return File(pickedImage.path);
    }
  }

  @override
  Future<File?> cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image'.tr,
          toolbarWidgetColor: AppColor.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
          title: 'Crop Image'.tr,
        )
      ],
    );
    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null;
    }
  }
}
