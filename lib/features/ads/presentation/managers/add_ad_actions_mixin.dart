import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/domain/entities/create_ad_request.dart';
import 'package:heraj_meem/features/ads/domain/use_case/create_ad_use_case.dart';
import 'package:heraj_meem/features/ads/presentation/view/ad_details_screen.dart';
import 'package:heraj_meem/features/ads/presentation/view/add_ad_screen.dart';
import 'package:heraj_meem/features/home/data/models/baho_feed.dart';
import 'package:heraj_meem/features/root/view/root_view.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';

final addAdStepIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class AddAdPhoto {
  final String path;
  final String mediaId;

  const AddAdPhoto({required this.path, required this.mediaId});
}

mixin AddAdActionsMixin on ConsumerState<AddAdScreen> {
  final PageController pageController = PageController();
  final ImagePicker imagePicker = ImagePicker();
  final titleFocus = FocusNode();
  final priceFocus = FocusNode();
  final descriptionFocus = FocusNode();
  late final FormGroup form = FormGroup({
    'title': FormControl<String>(validators: [Validators.required]),
    'price': FormControl<String>(validators: [Validators.required]),
    'description': FormControl<String>(
      validators: [Validators.required, Validators.minLength(10)],
    ),
  });

  final selectedCity = ValueNotifier<BahoCity?>(null);
  final selectedCategory = ValueNotifier<BahoCategory?>(null);
  final photos = ValueNotifier<List<AddAdPhoto>>([]);
  final showPhone = ValueNotifier(true);
  final createdAdId = ValueNotifier<String?>(null);
  final submitting = ValueNotifier(false);
  final categoryTrail = ValueNotifier<List<BahoCategory>>([]);

  void disposeAddAd() {
    pageController.dispose();
    titleFocus.dispose();
    priceFocus.dispose();
    descriptionFocus.dispose();
    form.dispose();
    selectedCity.dispose();
    selectedCategory.dispose();
    photos.dispose();
    showPhone.dispose();
    createdAdId.dispose();
    submitting.dispose();
    categoryTrail.dispose();
  }

  void handleBack() {
    final step = ref.read(addAdStepIndexProvider);
    if (step == 0) {
      Get.back();
      return;
    }
    ref.read(addAdStepIndexProvider.notifier).state = step - 1;
    pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> handleContinue() async {
    final step = ref.read(addAdStepIndexProvider);
    if (step == 0) {
      if (selectedCity.value == null) {
        _snack('Please select a city'.tr, AppColor.danger);
        return;
      }
      _next();
      return;
    }
    if (step == 1) {
      if (selectedCategory.value == null) {
        _snack('Please select a category'.tr, AppColor.danger);
        return;
      }
      _next();
      return;
    }
    if (step == 2) await submitAd();
  }

  void _next() {
    final step = ref.read(addAdStepIndexProvider);
    ref.read(addAdStepIndexProvider.notifier).state = step + 1;
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> pickImages() async {
    final picked = await imagePicker.pickMultiImage();
    if (picked.isEmpty || !mounted) return;
    final room = 20 - photos.value.length;
    if (room <= 0) return;
    _snack('Uploading images...'.tr, AppColor.primary);
    final uploaded = <AddAdPhoto>[];
    for (final image in picked.take(room)) {
      final result = await getIt<UploadAdMediaUseCase>().call(File(image.path));
      final id = result.fold((failure) {
        _snack(failure.message, AppColor.danger);
        return null;
      }, (mediaId) => mediaId);
      if (id != null && id.isNotEmpty) {
        uploaded.add(AddAdPhoto(path: image.path, mediaId: id));
      }
    }
    if (!mounted || uploaded.isEmpty) return;
    photos.value = [...photos.value, ...uploaded];
  }

  Future<void> removeImage(int index) async {
    final current = [...photos.value];
    if (index < 0 || index >= current.length) return;
    final photo = current[index];
    final result = await getIt<DeleteAdMediaUseCase>().call(photo.mediaId);
    result.fold((failure) {
      _snack(failure.message, AppColor.danger);
    }, (_) {
      current.removeAt(index);
      photos.value = current;
    });
  }

  Future<void> submitAd() async {
    form.markAllAsTouched();
    final title = form.control('title').value?.toString().trim() ?? '';
    final description =
        form.control('description').value?.toString().trim() ?? '';
    final price = num.tryParse(form.control('price').value?.toString().trim() ?? '');
    if (title.isEmpty) {
      _snack('Please enter product title'.tr, AppColor.danger);
      return;
    }
    if (price == null) {
      _snack('Please enter product price'.tr, AppColor.danger);
      return;
    }
    if (description.isEmpty) {
      _snack('Please enter a description'.tr, AppColor.danger);
      return;
    }
    if (description.length < 10) {
      _snack('Description must be at least 10 characters'.tr, AppColor.danger);
      return;
    }
    if (photos.value.isEmpty) {
      _snack('Please add at least one image'.tr, AppColor.danger);
      return;
    }
    final city = selectedCity.value;
    final category = selectedCategory.value;
    if (city == null || category == null) return;

    submitting.value = true;
    _snack('Creating ad...'.tr, AppColor.primary);
    final mediaIds = photos.value.map((photo) => photo.mediaId).toList();
    final created = await getIt<CreateAdUseCase>().call(
      CreateAdRequest(
        categoryId: category.id,
        cityId: city.id,
        title: title,
        description: description,
        price: price,
        showPhone: showPhone.value,
        mediaIds: mediaIds,
      ),
    );
    if (!mounted) return;
    final adId = created.fold((failure) {
      submitting.value = false;
      _snack(failure.message, AppColor.danger);
      return null;
    }, (id) => id);
    if (adId == null) return;

    if (adId.isNotEmpty && mediaIds.isNotEmpty) {
      final promoted = await getIt<PromoteAdMediaUseCase>().call(
        PromoteAdMediaParam(adId: adId, mediaIds: mediaIds),
      );
      if (!mounted) return;
      promoted.fold((failure) => _snack(failure.message, AppColor.danger), (_) {});
    }

    submitting.value = false;
    createdAdId.value = adId;
    _snack('Ad created successfully'.tr, AppColor.green);
    _next();
  }

  void viewCreatedAd() {
    final adId = createdAdId.value;
    if (adId == null || adId.isEmpty) return;
    Get.to(() => AdDetailsScreen(productId: adId));
  }

  void goHome() => Get.offAll(() => const RootView());

  void _snack(String text, Color color) {
    if (!mounted) return;
    UIHelper.showGlobalSnackBar(text: text, color: color);
  }
}
