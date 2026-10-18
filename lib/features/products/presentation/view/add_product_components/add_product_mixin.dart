import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/features/categories/data/models/main_category_model.dart';
import 'package:heraj/features/location/data/models/city_model.dart';
import 'package:heraj/features/location/data/models/district_model.dart';
import 'package:heraj/features/profile/domain/use_cases/upload_file_use_case.dart';
import 'package:heraj/features/products/domain/use_case/create_product_use_case.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import '../add_product_screen.dart';

mixin AddProductMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  // Controllers
  late final PageController pageController = PageController();
  late final TextEditingController titleController =
      TextEditingController(text: 'iPhone 15 Pro Max 256GB');
  late final TextEditingController priceController = TextEditingController();
  late final HtmlEditorController descriptionController = HtmlEditorController();
  late final TextEditingController stockController = TextEditingController();
  late final ImagePicker imagePicker = ImagePicker();

  // State variables
  CityModel? selectedCity;
  DistrictModel? selectedDistrict;
  NeighborhoodModel? selectedNeighborhood;
  CategoryModel? selectedCategory;
  String? adType;
  String? productType;
  List<String> selectedImages = [];
  List<Map<String, dynamic>> variants = [];
  Map<String, dynamic>? createdProductData;

  // Cached values for performance
  String? _cachedStepTitle;
  int? _cachedStepIndex;

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void nextStep(WidgetRef ref) {
    final currentStep = ref.read(addProductStepIndexProvider);
    if (currentStep < 3) {
      ref.read(addProductStepIndexProvider.notifier).state = currentStep + 1;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> pickImages() async {
    final List<XFile> images = await imagePicker.pickMultiImage();
    if (images.isEmpty) return;

    final limitedImages = images.take(20).toList();

    if (!mounted) return;

    UIHelper.showGlobalSnackBar(
      text: 'Uploading images...'.tr,
      color: AppColor.primary,
    );

    try {
      final List<String> uploadedPaths = [];
      final uploadFileUseCase = getIt<UploadFileUseCase>();

      // Upload images in parallel for better performance
      final uploadFutures = limitedImages.map((xFile) async {
        try {
          final file = File(xFile.path);
          final result = await uploadFileUseCase.call(file);
          return result.fold(
            (failure) {
              if (mounted) {
                UIHelper.showGlobalSnackBar(
                  text: '${"Failed to upload image:".tr} ${xFile.name}',
                  color: AppColor.danger,
                );
              }
              return null;
            },
            (uploadFileModel) {
              final uploadedPath = uploadFileModel.filePath;
              if (uploadedPath.isEmpty) {
                if (mounted) {
                  UIHelper.showGlobalSnackBar(
                    text:
                        '${"Failed to upload image:".tr} ${xFile.name} - ${"Empty response".tr}',
                    color: AppColor.danger,
                  );
                }
                return null;
              }
              return uploadedPath;
            },
          );
        } catch (e) {
          if (mounted) {
            UIHelper.showGlobalSnackBar(
              text:
                  '${"Failed to upload image:".tr} ${xFile.name} - ${e.toString()}',
              color: AppColor.danger,
            );
          }
          return null;
        }
      });

      final results = await Future.wait(uploadFutures);
      uploadedPaths.addAll(results.whereType<String>());

      if (uploadedPaths.isNotEmpty && mounted) {
        setState(() {
          selectedImages = [...selectedImages, ...uploadedPaths];
          if (selectedImages.length > 20) {
            selectedImages = selectedImages.take(20).toList();
          }
        });

        if (mounted) {
          UIHelper.showGlobalSnackBar(
            text:
                '${uploadedPaths.length} ${"image(s) uploaded successfully".tr}',
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
    }
  }

  Future<void> submitAd(WidgetRef ref) async {
    // Validation
    if (titleController.text.trim().isEmpty) {
      UIHelper.showGlobalSnackBar(
        text: 'Please enter product title'.tr,
        color: AppColor.danger,
      );
      return;
    }
    if (selectedCategory == null) {
      UIHelper.showGlobalSnackBar(
        text: 'Please select a category'.tr,
        color: AppColor.danger,
      );
      return;
    }
    if (priceController.text.trim().isEmpty) {
      UIHelper.showGlobalSnackBar(
        text: 'Please enter product price'.tr,
        color: AppColor.danger,
      );
      return;
    }
    if (selectedImages.isEmpty) {
      UIHelper.showGlobalSnackBar(
        text: 'Please add at least one image'.tr,
        color: AppColor.danger,
      );
      return;
    }

    if (!mounted) return;

    UIHelper.showGlobalSnackBar(
      text: 'Creating product...'.tr,
      color: AppColor.primary,
    );

    try {
      final createProductUseCase = getIt<CreateProductUseCase>();
      final htmlDescription = await descriptionController.getText();
      final user = ref.read(userProvider);
      
      final productData = {
        "productType": user?.role ?? "customer",
        'title': titleController.text.trim(),
        'description': htmlDescription,
        'price': double.tryParse(priceController.text.trim()) ?? 0.0,
        'category': selectedCategory!.id,
        'stock': int.tryParse(stockController.text.trim()) ?? 0,
        'images': selectedImages,
        "condition": adType?.toLowerCase(),
        if (selectedCity != null)
          'location': {
            'city': selectedCity!.name,
            if (selectedDistrict != null) 'district': selectedDistrict!.name,
            if (selectedNeighborhood != null)
              'neighborhood': selectedNeighborhood!.name,
          },
        if (variants.isNotEmpty) 'variants': variants,
      };

      final result = await createProductUseCase.call(productData);

      if (!mounted) return;

      result.fold(
        (failure) {
          UIHelper.showGlobalSnackBar(
            text: failure.message,
            color: AppColor.danger,
          );
        },
        (data) {
          setState(() {
            createdProductData = data;
          });
          UIHelper.showGlobalSnackBar(
            text: 'Product created successfully!'.tr,
            color: AppColor.green,
          );
          nextStep(ref);
        },
      );
    } catch (e) {
      if (mounted) {
        UIHelper.showGlobalSnackBar(
          text: '${"Error creating product:".tr} ${e.toString()}',
          color: AppColor.danger,
        );
      }
    }
  }

  String getStepTitle(int step) {
    // Cache the result if step hasn't changed
    if (_cachedStepTitle != null && _cachedStepIndex == step) {
      return _cachedStepTitle!;
    }

    _cachedStepIndex = step;
    _cachedStepTitle = switch (step) {
      0 => 'Select City'.tr,
      1 => 'Select Category'.tr,
      2 => 'Ad Details'.tr,
      3 => 'Ad Pending'.tr,
      _ => '',
    };

    return _cachedStepTitle!;
  }

  void showProductInfoBottomSheet(
      BuildContext context, Map<String, dynamic> productData) {
    final product = productData['product'] as Map<String, dynamic>?;
    if (product == null) return;

    // This will be implemented in the screen file
    // The mixin just provides the method signature
  }

  void handleBackButton(WidgetRef ref) {
    final currentStep = ref.read(addProductStepIndexProvider);
    if (currentStep == 0) {
      Get.back();
    } else {
      ref.read(addProductStepIndexProvider.notifier).state = currentStep - 1;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void handleContinueButton(WidgetRef ref) {
    final currentStep = ref.read(addProductStepIndexProvider);
    
    // Validation for each step
    if (currentStep == 0 &&
        (selectedCity == null ||
            selectedDistrict == null ||
            selectedNeighborhood == null)) {
      return;
    }
    if (currentStep == 1 && selectedCategory == null) {
      return;
    }
    if (currentStep == 2) {
      submitAd(ref);
    } else {
      nextStep(ref);
    }
  }

  void onCitySelected(CityModel city) {
    setState(() {
      selectedCity = city;
      selectedDistrict = null;
      selectedNeighborhood = null;
    });
  }

  void onDistrictSelected(DistrictModel? district) {
    setState(() {
      selectedDistrict = district;
      selectedNeighborhood = null;
    });
  }

  void onNeighborhoodSelected(NeighborhoodModel? neighborhood) {
    setState(() {
      selectedNeighborhood = neighborhood;
    });
  }

  void onCategorySelected(CategoryModel category) {
    setState(() {
      selectedCategory = category;
    });
  }

  void onAdTypeChanged(String? type) {
    setState(() {
      adType = type;
    });
  }

  void onProductTypeChanged(String? type) {
    setState(() {
      productType = type;
    });
  }

  void onVariantsChanged(List<Map<String, dynamic>> newVariants) {
    setState(() {
      variants = newVariants;
    });
  }

  void disposeControllers() {
    pageController.dispose();
    titleController.dispose();
    priceController.dispose();
    stockController.dispose();
  }
}

