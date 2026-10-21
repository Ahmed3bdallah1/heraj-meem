import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/ads/data/models/product_details_model.dart';
import 'package:heraj_meem/features/ads/domain/entities/create_ad_request.dart';
import 'package:heraj_meem/features/ads/domain/use_case/create_ad_use_case.dart';
import 'package:heraj_meem/features/ads/presentation/managers/products_managers.dart';
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
  final String? mediaId;

  const AddAdPhoto({required this.path, this.mediaId});

  bool get isRemote => path.startsWith('http');
}

class AddAdAttributeFocus {
  final FocusNode name = FocusNode();
  final FocusNode value = FocusNode();

  void dispose() {
    name.dispose();
    value.dispose();
  }
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
    'attributes': FormArray<Map<String, Object?>>([]),
  });
  final attributeFocus = <AddAdAttributeFocus>[];

  final selectedCity = ValueNotifier<BahoCity?>(null);
  final selectedCategory = ValueNotifier<BahoCategory?>(null);
  final photos = ValueNotifier<List<AddAdPhoto>>([]);
  final showPhone = ValueNotifier(true);
  final createdAdId = ValueNotifier<String?>(null);
  final publishing = ValueNotifier(false);
  String? editingAdId;
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
    publishing.dispose();
    submitting.dispose();
    categoryTrail.dispose();
    for (final focus in attributeFocus) {
      focus.dispose();
    }
  }

  void handleBack() {
    final step = ref.read(addAdStepIndexProvider);
    if (step >= 3) return;
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
    photos.value = [
      ...photos.value,
      ...picked.take(room).map((image) => AddAdPhoto(path: image.path)),
    ];
  }

  void addAttribute() {
    attributeFocus.add(AddAdAttributeFocus());
    attributesArray.add(
      FormGroup({
        'name': FormControl<String>(value: ''),
        'value': FormControl<String>(value: ''),
      }),
    );
  }

  void removeAttribute(int index) {
    if (index < 0 || index >= attributesArray.controls.length) return;
    final focus = attributeFocus.removeAt(index);
    attributesArray.removeAt(index);
    focus.dispose();
  }

  FormArray<Map<String, Object?>> get attributesArray =>
      form.control('attributes') as FormArray<Map<String, Object?>>;

  List<Map<String, String>> _attributes() {
    final attributes = <Map<String, String>>[];
    for (final control in attributesArray.controls) {
      final group = control as FormGroup;
      final name = group.control('name').value?.toString().trim() ?? '';
      final value = group.control('value').value?.toString().trim() ?? '';
      if (name.isEmpty || value.isEmpty) continue;
      attributes.add({name: value});
    }
    return attributes;
  }

  void prefillAd(ProductDetailsModel ad) {
    editingAdId = ad.id;
    form.control('title').value = ad.name;
    form.control('price').value = _priceText(ad.price);
    form.control('description').value = ad.description;
    showPhone.value = ad.showPhone ?? true;
    final cityId = ad.cityId ?? '';
    if (cityId.isNotEmpty) {
      final cityName = ad.location?.city ?? '';
      selectedCity.value = BahoCity(
        id: cityId,
        regionId: ad.regionId ?? '',
        nameAr: cityName,
        nameEn: cityName,
        slug: '',
      );
    }
    final category = ad.adminCategory;
    final categoryId = ad.categoryId ?? category?.id ?? '';
    if (categoryId.isNotEmpty) {
      selectedCategory.value = BahoCategory(
        id: categoryId,
        slug: category?.slug ?? '',
        nameAr: category?.nameAr ?? category?.name ?? '',
        nameEn: category?.nameTr ?? category?.name ?? '',
        imageUrl: category?.image,
      );
    }
    final fields = ad.categorySpecificFields ?? {};
    for (final entry in fields.entries) {
      final name = entry.key.trim();
      final value = entry.value?.toString().trim() ?? '';
      if (name.isEmpty || value.isEmpty) continue;
      addAttribute();
      final group = attributesArray.controls.last as FormGroup;
      group.control('name').value = name;
      group.control('value').value = value;
    }
    final mediaIds = ad.mediaIds ?? const <String>[];
    photos.value = [
      for (var index = 0; index < ad.images.length; index++)
        AddAdPhoto(
          path: ad.images[index],
          mediaId: index < mediaIds.length && mediaIds[index].isNotEmpty
              ? mediaIds[index]
              : null,
        ),
    ];
  }

  void removeImage(int index) {
    final current = [...photos.value];
    if (index < 0 || index >= current.length) return;
    final photo = current.removeAt(index);
    photos.value = current;
    final mediaId = photo.mediaId;
    if (mediaId == null || mediaId.isEmpty) return;
    getIt<DeleteAdMediaUseCase>().call(mediaId).then((result) {
      if (!mounted) return;
      result.fold((failure) {
        final restored = [...photos.value];
        restored.insert(index.clamp(0, restored.length), photo);
        photos.value = restored;
        _snack(failure.message, AppColor.danger);
      }, (_) {});
    });
  }

  String _priceText(double price) {
    if (price <= 0) return '';
    if (price == price.roundToDouble()) return price.toInt().toString();
    return price.toString();
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
    final editingId = editingAdId;
    _snack(
      (editingId == null ? 'Creating ad...' : 'Updating ad...').tr,
      AppColor.primary,
    );
    final request = CreateAdRequest(
      categoryId: category.id,
      cityId: city.id,
      title: title,
      description: description,
      price: price,
      showPhone: showPhone.value,
      imagePaths: photos.value
          .map((photo) => photo.path)
          .where((path) => !path.startsWith('http'))
          .toList(),
      attributes: _attributes(),
    );
    final created = editingId == null
        ? await getIt<CreateAdUseCase>().call(request)
        : await getIt<UpdateAdUseCase>().call(
            UpdateAdParam(adId: editingId, request: request),
          );
    if (!mounted) return;
    final adId = created.fold((failure) {
      submitting.value = false;
      _snack(failure.message, AppColor.danger);
      return null;
    }, (id) => id);
    if (adId == null) return;

    submitting.value = false;
    if (editingId != null) {
      ref.invalidate(fetchProductByIdProvider(editingId));
      ref.invalidate(fetchMyAdProvider(editingId));
      ref.invalidate(fetchMyAdsProvider);
      _snack('Ad updated successfully'.tr, AppColor.green);
      Get.back();
      return;
    }
    createdAdId.value = adId;
    _snack('Ad created successfully'.tr, AppColor.green);
    _next();
  }

  void viewCreatedAd() {
    final adId = createdAdId.value;
    if (adId == null || adId.isEmpty) return;
    Get.off(() => AdDetailsScreen(productId: adId, mine: true));
  }

  Future<void> publishCreatedAd() async {
    final adId = createdAdId.value;
    if (adId == null || adId.isEmpty || publishing.value) return;
    publishing.value = true;
    final result = await getIt<PublishAdUseCase>().call(adId);
    if (!mounted) return;
    publishing.value = false;
    result.fold((failure) {
      _snack(failure.message, AppColor.danger);
    }, (_) {
      Get.offAll(() => const RootView());
    });
  }

  void _snack(String text, Color color) {
    if (!mounted) return;
    UIHelper.showGlobalSnackBar(text: text, color: color);
  }
}
