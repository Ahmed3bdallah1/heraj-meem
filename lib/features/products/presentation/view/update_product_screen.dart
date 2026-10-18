import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/products/data/models/product_model.dart';
import 'package:heraj_meem/features/products/domain/use_case/update_product_use_case.dart';
import 'package:heraj_meem/features/profile/domain/use_cases/upload_file_use_case.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_text_field.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj_meem/ui/ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tuple/tuple.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class UpdateProductScreen extends ConsumerStatefulWidget {
  final ProductModel product;

  const UpdateProductScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends ConsumerState<UpdateProductScreen> {
  late FormGroup formGroup;
  final ImagePicker _imagePicker = ImagePicker();
  List<String> _selectedImages = [];
  bool _isLoading = false;
  final HtmlEditorController _descriptionController = HtmlEditorController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _selectedImages = List<String>.from(widget.product.images);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDescription();
    });
  }

  Future<void> _loadDescription() async {
    if (widget.product.description != null && widget.product.description!.isNotEmpty) {
      _descriptionController.setText(widget.product.description!);
    }
  }

  void _initializeForm() {
    formGroup = FormGroup({
      'name': FormControl<String>(
        value: widget.product.name,
        validators: [Validators.required],
      ),
      'sku': FormControl<String>(
        value: widget.product.sku,
        validators: [Validators.required],
      ),
      'price': FormControl<double>(
        value: widget.product.price,
        validators: [Validators.required],
      ),
      'compareAtPrice': FormControl<double>(
        value: widget.product.compareAtPrice,
      ),
      'stock': FormControl<int>(
        value: widget.product.stock,
        validators: [Validators.required],
      ),
      'status': FormControl<String>(
        value: widget.product.status,
        validators: [Validators.required],
      ),
      'productType': FormControl<String>(
        value: widget.product.productType,
        validators: [Validators.required],
      ),
      'titleTr': FormControl<String>(
        value: widget.product.titleTr,
      ),
      'titleAr': FormControl<String>(
        value: widget.product.titleAr,
      ),
      'descriptionTr': FormControl<String>(
        value: widget.product.descriptionTr,
      ),
      'descriptionAr': FormControl<String>(
        value: widget.product.descriptionAr,
      ),
      'adminCategory': FormControl<String>(
        value: widget.product.adminCategory,
      ),
      'condition': FormControl<String>(
        value: widget.product.condition,
      ),
      'isFeatured': FormControl<bool>(
        value: widget.product.isFeatured,
      ),
      'isFeaturedDeal': FormControl<bool>(
        value: widget.product.isFeaturedDeal,
      ),
      // Delivery Info
      'estimatedDays': FormControl<int>(
        value: widget.product.deliveryInfo?.estimatedDays,
      ),
      'freeShipping': FormControl<bool>(
        value: widget.product.deliveryInfo?.freeShipping ?? false,
      ),
      'isInTurkey': FormControl<bool>(
        value: widget.product.deliveryInfo?.isInTurkey ?? false,
      ),
      'freeShippingThreshold': FormControl<double>(
        value: widget.product.deliveryInfo?.freeShippingThreshold,
      ),
      // Warranty
      'hasWarranty': FormControl<bool>(
        value: widget.product.warranty?.hasWarranty ?? false,
      ),
      'warrantyDuration': FormControl<String>(
        value: widget.product.warranty?.duration,
      ),
      'warrantyDurationAr': FormControl<String>(
        value: widget.product.warranty?.durationAr,
      ),
      'warrantyDurationTr': FormControl<String>(
        value: widget.product.warranty?.durationTr,
      ),
      'warrantyDescription': FormControl<String>(
        value: widget.product.warranty?.description,
      ),
      // Location
      'city': FormControl<String>(
        value: widget.product.location?.city,
      ),
      'district': FormControl<String>(
        value: widget.product.location?.district,
      ),
      'neighborhood': FormControl<String>(
        value: widget.product.location?.neighborhood,
      ),
      'street': FormControl<String>(
        value: widget.product.location?.street,
      ),
    });
  }

  @override
  void dispose() {
    formGroup.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      final limitedImages = images.take(20).toList();

      if (mounted) {
        UIHelper.showGlobalSnackBar(
          text: 'Uploading images...'.tr,
          color: AppColor.primary,
        );
      }

      try {
        final List<String> uploadedPaths = [];
        final uploadFileUseCase = getIt<UploadFileUseCase>();

        for (final xFile in limitedImages) {
          final file = File(xFile.path);

          try {
            final result = await uploadFileUseCase.call(file);
            result.fold(
              (failure) {
                if (mounted) {
                  UIHelper.showGlobalSnackBar(
                    text: '${"Failed to upload image:".tr} ${xFile.name}',
                    color: AppColor.danger,
                  );
                }
              },
              (uploadFileModel) {
                final uploadedPath = uploadFileModel.filePath;
                if (uploadedPath.isNotEmpty) {
                  uploadedPaths.add(uploadedPath);
                }
              },
            );
          } catch (e) {
            if (mounted) {
              UIHelper.showGlobalSnackBar(
                text: '${"Failed to upload image:".tr} ${xFile.name}',
                color: AppColor.danger,
              );
            }
          }
        }

        if (uploadedPaths.isNotEmpty && mounted) {
          setState(() {
            _selectedImages = [..._selectedImages, ...uploadedPaths];
            if (_selectedImages.length > 20) {
              _selectedImages = _selectedImages.take(20).toList();
            }
          });

          if (mounted) {
            UIHelper.showGlobalSnackBar(
              text: '${uploadedPaths.length} ${"image(s) uploaded successfully".tr}',
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
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Map<String, dynamic> _cleanFormData(Map<String, dynamic> data) {
    final cleaned = <String, dynamic>{};

    data.forEach((key, value) {
      if (value == null) {
        return;
      }

      if (value is String && value.trim().isEmpty) {
        return;
      }

      if (value is List) {
        if (value.isEmpty) {
          cleaned[key] = [];
        } else {
          cleaned[key] = value;
        }
        return;
      }

      if (value is Map) {
        final cleanedMap = _cleanFormData(Map<String, dynamic>.from(value));
        if (cleanedMap.isNotEmpty) {
          cleaned[key] = cleanedMap;
        }
        return;
      }

      cleaned[key] = value;
    });

    return cleaned;
  }

  Future<void> _submitForm() async {
    if (!formGroup.valid) {
      formGroup.markAllAsTouched();
      UIHelper.showGlobalSnackBar(
        text: 'Please fill all required fields'.tr,
        color: AppColor.danger,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formValue = formGroup.value;
      final htmlDescription = await _descriptionController.getText();

      final productData = <String, dynamic>{
        'name': formValue['name'],
        'title': formValue['name'],
        'sku': formValue['sku'],
        'price': formValue['price'],
        if (formValue['compareAtPrice'] != null)
          'compareAtPrice': formValue['compareAtPrice'],
        'stock': formValue['stock'],
        'status': formValue['status'],
        'productType': formValue['productType'],
        if (htmlDescription.isNotEmpty) 'description': htmlDescription,
        if (formValue['titleTr'] != null && formValue['titleTr'].toString().trim().isNotEmpty)
          'titleTr': formValue['titleTr'],
        if (formValue['titleAr'] != null && formValue['titleAr'].toString().trim().isNotEmpty)
          'titleAr': formValue['titleAr'],
        if (formValue['descriptionTr'] != null && formValue['descriptionTr'].toString().trim().isNotEmpty)
          'descriptionTr': formValue['descriptionTr'],
        if (formValue['descriptionAr'] != null && formValue['descriptionAr'].toString().trim().isNotEmpty)
          'descriptionAr': formValue['descriptionAr'],
        if (formValue['adminCategory'] != null && formValue['adminCategory'].toString().trim().isNotEmpty)
          'adminCategory': formValue['adminCategory'],
        if (formValue['condition'] != null && formValue['condition'].toString().trim().isNotEmpty)
          'condition': formValue['condition'],
        'isFeatured': formValue['isFeatured'] ?? false,
        'isFeaturedDeal': formValue['isFeaturedDeal'] ?? false,
        'images': _selectedImages.isEmpty ? [] : _selectedImages,
        'badges': widget.product.badges.isEmpty ? [] : widget.product.badges,
        'variants': widget.product.variants.isEmpty ? [] : widget.product.variants,
        'variantCombinations': widget.product.variantCombinations.isEmpty
            ? []
            : widget.product.variantCombinations,
        'specifications': widget.product.specifications.isEmpty
            ? []
            : widget.product.specifications,
      };

      if (formValue['estimatedDays'] != null ||
          formValue['freeShipping'] != null ||
          formValue['isInTurkey'] != null ||
          formValue['freeShippingThreshold'] != null) {
        final deliveryInfo = <String, dynamic>{};
        if (formValue['estimatedDays'] != null) {
          deliveryInfo['estimatedDays'] = formValue['estimatedDays'];
        }
        if (formValue['freeShipping'] != null) {
          deliveryInfo['freeShipping'] = formValue['freeShipping'];
        }
        if (formValue['isInTurkey'] != null) {
          deliveryInfo['isInTurkey'] = formValue['isInTurkey'];
        }
        if (formValue['freeShippingThreshold'] != null) {
          deliveryInfo['freeShippingThreshold'] = formValue['freeShippingThreshold'];
        }
        if (deliveryInfo.isNotEmpty) {
          productData['deliveryInfo'] = deliveryInfo;
        }
      }

      if (formValue['hasWarranty'] != null ||
          formValue['warrantyDuration'] != null ||
          formValue['warrantyDurationAr'] != null ||
          formValue['warrantyDurationTr'] != null ||
          formValue['warrantyDescription'] != null) {
        final warranty = <String, dynamic>{};
        if (formValue['hasWarranty'] != null) {
          warranty['hasWarranty'] = formValue['hasWarranty'];
        }
        if (formValue['warrantyDuration'] != null &&
            formValue['warrantyDuration'].toString().trim().isNotEmpty) {
          warranty['duration'] = formValue['warrantyDuration'];
        }
        if (formValue['warrantyDurationAr'] != null &&
            formValue['warrantyDurationAr'].toString().trim().isNotEmpty) {
          warranty['durationAr'] = formValue['warrantyDurationAr'];
        }
        if (formValue['warrantyDurationTr'] != null &&
            formValue['warrantyDurationTr'].toString().trim().isNotEmpty) {
          warranty['durationTr'] = formValue['warrantyDurationTr'];
        }
        if (formValue['warrantyDescription'] != null &&
            formValue['warrantyDescription'].toString().trim().isNotEmpty) {
          warranty['description'] = formValue['warrantyDescription'];
        }
        if (warranty.isNotEmpty) {
          productData['warranty'] = warranty;
        }
      }

      if (formValue['city'] != null ||
          formValue['district'] != null ||
          formValue['neighborhood'] != null ||
          formValue['street'] != null) {
        final location = <String, dynamic>{};
        if (formValue['city'] != null && formValue['city'].toString().trim().isNotEmpty) {
          location['city'] = formValue['city'];
        }
        if (formValue['district'] != null &&
            formValue['district'].toString().trim().isNotEmpty) {
          location['district'] = formValue['district'];
        }
        if (formValue['neighborhood'] != null &&
            formValue['neighborhood'].toString().trim().isNotEmpty) {
          location['neighborhood'] = formValue['neighborhood'];
        }
        if (formValue['street'] != null &&
            formValue['street'].toString().trim().isNotEmpty) {
          location['street'] = formValue['street'];
        }
        if (location.isNotEmpty) {
          productData['location'] = location;
        }
      }

      final cleanedData = _cleanFormData(productData);

      final updateProductUseCase = getIt<UpdateProductUseCase>();
      final result = await updateProductUseCase.call(
        Tuple2(widget.product.id, cleanedData),
      );

      result.fold(
        (failure) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            UIHelper.showGlobalSnackBar(
              text: failure.message,
              color: AppColor.danger,
            );
          }
        },
        (data) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            UIHelper.showGlobalSnackBar(
              text: 'Product updated successfully!'.tr,
              color: AppColor.green,
            );
            Get.back(result: true);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        UIHelper.showGlobalSnackBar(
          text: '${"Error updating product:".tr} ${e.toString()}',
          color: AppColor.danger,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Update Product'.tr,
          style: AppFont.font18W700Black,
        ),
        centerTitle: true,
      ),
      body: ReactiveForm(
        formGroup: formGroup,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Information'.tr,
                style: AppFont.font18W700Black,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'name',
                labelText: 'Product Name'.tr,
                hintText: 'Enter product name'.tr,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'sku',
                labelText: 'SKU'.tr,
                hintText: 'Enter SKU'.tr,
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField<double>(
                      formControlName: 'price',
                      labelText: 'Price'.tr,
                      hintText: '0.0',
                      inputType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: CustomTextField<double>(
                      formControlName: 'compareAtPrice',
                      labelText: 'Compare At Price'.tr,
                      hintText: '0.0',
                      inputType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField<int>(
                      formControlName: 'stock',
                      labelText: 'Stock'.tr,
                      hintText: '0',
                      inputType: TextInputType.number,
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'condition',
                labelText: 'Condition'.tr,
                hintText: 'Enter condition (e.g., new, used)'.tr,
              ),
              const Gap(24),

              Text(
                'Multilingual Information'.tr,
                style: AppFont.font18W700Black,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'titleTr',
                labelText: 'Title (Turkish)'.tr,
                hintText: 'Enter Turkish title'.tr,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'titleAr',
                labelText: 'Title (Arabic)'.tr,
                hintText: 'Enter Arabic title'.tr,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'descriptionTr',
                labelText: 'Description (Turkish)'.tr,
                hintText: 'Enter Turkish description'.tr,
                maxLines: 3,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'descriptionAr',
                labelText: 'Description (Arabic)'.tr,
                hintText: 'Enter Arabic description'.tr,
                maxLines: 3,
              ),
              const Gap(24),

              // Description Section
              Text(
                'Description'.tr,
                style: AppFont.font18W700Black,
              ),
              const Gap(16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.grey1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HtmlEditor(
                  controller: _descriptionController,
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: 'Enter product description'.tr,
                    shouldEnsureVisible: true,
                    initialText: widget.product.description ?? '',
                  ),
                  htmlToolbarOptions: HtmlToolbarOptions(
                    defaultToolbarButtons: [
                      StyleButtons(),
                      FontSettingButtons(),
                      ColorButtons(),
                      ListButtons(),
                      ParagraphButtons(),
                      InsertButtons(),
                    ],
                  ),
                ),
              ),
              const Gap(24),

              // Images Section
              Text(
                'Product Images'.tr,
                style: AppFont.font18W700Black,
              ),
              const Gap(16),
              if (_selectedImages.isNotEmpty)
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.grey1),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ImageOrSvg(
                                _selectedImages[index],
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: EdgeInsets.all(4),
                                  minimumSize: Size(32, 32),
                                ),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const Gap(16),
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: Icon(Icons.add_photo_alternate, color: AppColor.primary),
                label: Text('Add Images'.tr),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppColor.primary),
                ),
              ),
              const Gap(24),

              // Delivery Information
              Text(
                'Delivery Information'.tr,
                style: AppFont.font18W700Black,
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField<int>(
                      formControlName: 'estimatedDays',
                      labelText: 'Estimated Days'.tr,
                      hintText: '0',
                      inputType: TextInputType.number,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: CustomTextField<double>(
                      formControlName: 'freeShippingThreshold',
                      labelText: 'Free Shipping Threshold'.tr,
                      hintText: '0.0',
                      inputType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              ReactiveValueListenableBuilder<bool>(
                formControlName: 'freeShipping',
                builder: (context, control, child) {
                  return CheckboxListTile(
                    title: Text('Free Shipping'.tr),
                    value: control.value ?? false,
                    onChanged: control.enabled
                        ? (value) {
                            control.value = value;
                          }
                        : null,
                  );
                },
              ),
              const Gap(8),
              ReactiveValueListenableBuilder<bool>(
                formControlName: 'isInTurkey',
                builder: (context, control, child) {
                  return CheckboxListTile(
                    title: Text('Is In Turkey'.tr),
                    value: control.value ?? false,
                    onChanged: control.enabled
                        ? (value) {
                            control.value = value;
                          }
                        : null,
                  );
                },
              ),
              const Gap(24),

              // Warranty Information
              Text(
                'Warranty Information'.tr,
                style: AppFont.font18W700Black,
              ),
              const Gap(16),
              ReactiveValueListenableBuilder<bool>(
                formControlName: 'hasWarranty',
                builder: (context, control, child) {
                  return CheckboxListTile(
                    title: Text('Has Warranty'.tr),
                    value: control.value ?? false,
                    onChanged: control.enabled
                        ? (value) {
                            control.value = value;
                          }
                        : null,
                  );
                },
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'warrantyDuration',
                labelText: 'Warranty Duration'.tr,
                hintText: 'Enter warranty duration'.tr,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'warrantyDurationAr',
                labelText: 'Warranty Duration (Arabic)'.tr,
                hintText: 'Enter warranty duration in Arabic'.tr,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'warrantyDurationTr',
                labelText: 'Warranty Duration (Turkish)'.tr,
                hintText: 'Enter warranty duration in Turkish'.tr,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'warrantyDescription',
                labelText: 'Warranty Description'.tr,
                hintText: 'Enter warranty description'.tr,
                maxLines: 2,
              ),
              const Gap(24),

              // Location Information
              Text(
                'Location Information'.tr,
                style: AppFont.font18W700Black,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'city',
                labelText: 'City'.tr,
                hintText: 'Enter city'.tr,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'district',
                labelText: 'District'.tr,
                hintText: 'Enter district'.tr,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'neighborhood',
                labelText: 'Neighborhood'.tr,
                hintText: 'Enter neighborhood'.tr,
              ),
              const Gap(16),
              CustomTextField<String>(
                formControlName: 'street',
                labelText: 'Street'.tr,
                hintText: 'Enter street'.tr,
              ),
              const Gap(24),

              // Feature Flags
              Text(
                'Feature Flags'.tr,
                style: AppFont.font18W700Black,
              ),
              const Gap(16),
              ReactiveValueListenableBuilder<bool>(
                formControlName: 'isFeatured',
                builder: (context, control, child) {
                  return CheckboxListTile(
                    title: Text('Is Featured'.tr),
                    value: control.value ?? false,
                    onChanged: control.enabled
                        ? (value) {
                            control.value = value;
                          }
                        : null,
                  );
                },
              ),
              const Gap(8),
              ReactiveValueListenableBuilder<bool>(
                formControlName: 'isFeaturedDeal',
                builder: (context, control, child) {
                  return CheckboxListTile(
                    title: Text('Is Featured Deal'.tr),
                    value: control.value ?? false,
                    onChanged: control.enabled
                        ? (value) {
                            control.value = value;
                          }
                        : null,
                  );
                },
              ),
              const Gap(24),

              // Submit Button
              CustomFilledButton(
                text: 'Update Product'.tr,
                onPressed: _submitForm,
                isLoading: _isLoading,
              ),
              Gap(MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
}

