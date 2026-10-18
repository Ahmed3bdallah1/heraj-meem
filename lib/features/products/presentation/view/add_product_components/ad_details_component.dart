import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import '../../../../../config/app_font.dart';
import '../../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../../../ui/ui.dart';

class AdDetailsStep extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController priceController;
  final HtmlEditorController descriptionController;
  final TextEditingController stockController;
  final List<String> selectedImages;
  final String? adType;
  final String? productType;
  final List<Map<String, dynamic>> variants;
  final ValueChanged<String> onAdTypeChanged;
  final ValueChanged<String> onProductTypeChanged;
  final VoidCallback onImagesPicked;
  final ValueChanged<int> onImageRemoved;
  final ValueChanged<List<Map<String, dynamic>>> onVariantsChanged;

  const AdDetailsStep({
    super.key,
    required this.titleController,
    required this.priceController,
    required this.descriptionController,
    required this.stockController,
    required this.selectedImages,
    required this.adType,
    required this.productType,
    required this.variants,
    required this.onAdTypeChanged,
    required this.onProductTypeChanged,
    required this.onImagesPicked,
    required this.onImageRemoved,
    required this.onVariantsChanged,
  });

  @override
  State<AdDetailsStep> createState() => _AdDetailsStepState();
}

class _AdDetailsStepState extends State<AdDetailsStep>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _addVariant() {
    showDialog(
      context: context,
      builder: (context) => _VariantDialog(
        onSave: (variant) {
          setState(() {
            widget.onVariantsChanged([...widget.variants, variant]);
          });
        },
      ),
    );
  }

  void _removeVariant(int index) {
    setState(() {
      final newVariants = List<Map<String, dynamic>>.from(widget.variants);
      newVariants.removeAt(index);
      widget.onVariantsChanged(newVariants);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColor.primary2.withAlpha(100),
              border: Border.all(color: AppColor.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: widget.selectedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 48, color: AppColor.grey2),
                      const Gap(8),
                      Text(
                        'Maximum limit: 20 photos'.tr,
                        style: AppFont.font12w400Black,
                      ),
                    ],
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: widget.selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ImageOrSvg(
                              widget.selectedImages[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => widget.onImageRemoved(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          TextButton.icon(
            onPressed: widget.onImagesPicked,
            icon: Icon(Icons.add_photo_alternate, color: AppColor.primary),
            label: Text(
              'Add Photos'.tr,
              style: AppFont.font14W600Primary,
            ),
          ),
          const Gap(16),
          TextField(
            controller: widget.titleController,
            style: AppFont.font16W700Black,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              FocusManager.instance.primaryFocus?.nextFocus();
            },
            decoration: InputDecoration(
              labelText: 'Ad Title'.tr,
              labelStyle: AppFont.labelTextField,
              fillColor: AppColor.primary2,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary)),
            ),
          ),
          const Gap(16),
          DropdownButtonFormField<String>(
            initialValue: widget.adType,
            style: AppFont.font16W700Black,
            decoration: InputDecoration(
              labelText: 'Ad Type'.tr,
              labelStyle: AppFont.labelTextField,
              fillColor: AppColor.primary2,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary)),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
            items: ['New', 'Used', 'Refurbished']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.tr,
                        style: AppFont.font14W500Black,
                      ),
                    ))
                .toList(),
            onChanged: (value) => widget.onAdTypeChanged(value ?? ''),
          ),
          const Gap(16),
          // Price
          TextField(
            controller: widget.priceController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            style: AppFont.font16W700Black,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) {
              FocusManager.instance.primaryFocus?.nextFocus();
            },
            decoration: InputDecoration(
              labelText: 'Price'.tr,
              labelStyle: AppFont.labelTextField,
              fillColor: AppColor.primary2,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary)),
            ),
          ),
          const Gap(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Description'.tr,
                style: AppFont.font14W700Black,
              ),
              const Gap(8),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.grey1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HtmlEditor(
                  controller: widget.descriptionController,
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: 'Enter product description here...'.tr,
                    shouldEnsureVisible: true,
                    characterLimit: 1000,
                    initialText: '',
                  ),
                  htmlToolbarOptions: HtmlToolbarOptions(
                    dropdownBackgroundColor: AppColor.primary2,
                    buttonBorderColor: AppColor.primary,
                    buttonSelectedColor: AppColor.primary,
                    buttonColor: AppColor.primary,
                    textStyle: AppFont.font14W700Black,
                    defaultToolbarButtons: [
                      const StyleButtons(),
                      const FontSettingButtons(
                        fontSizeUnit: false,
                      ),
                      const FontButtons(
                        clearAll: false,
                        strikethrough: false,
                        superscript: false,
                        subscript: false,
                      ),
                      const ColorButtons(),
                      const ListButtons(listStyles: false),
                      const ParagraphButtons(
                        textDirection: false,
                        lineHeight: false,
                        caseConverter: false,
                      ),
                      const InsertButtons(
                        video: false,
                        audio: false,
                        table: true,
                        hr: true,
                        otherFile: false,
                      ),
                      const OtherButtons(
                        fullscreen: false,
                        codeview: true,
                        undo: true,
                        redo: true,
                        copy: true,
                        paste: true,
                      ),
                    ],
                    toolbarPosition: ToolbarPosition.aboveEditor,
                    toolbarType: ToolbarType.nativeScrollable,
                  ),
                  otherOptions: const OtherOptions(
                    height: 300,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          TextField(
            controller: widget.stockController,
            style: AppFont.font16W700Black,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) {
              FocusManager.instance.primaryFocus?.nextFocus();
            },
            decoration: InputDecoration(
              labelText: 'Stock'.tr,
              labelStyle: AppFont.labelTextField,
              fillColor: AppColor.primary2,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary)),
            ),
          ),
          const Gap(16),
          // Variants Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Variants (e.g., Color, Size)'.tr,
                style: AppFont.font16W600Black,
              ),
              TextButton.icon(
                onPressed: _addVariant,
                icon: Icon(Icons.add, color: AppColor.primary),
                label: Text(
                  'Add'.tr,
                  style: AppFont.font14W600Primary,
                ),
              ),
            ],
          ),
          if (widget.variants.isNotEmpty) ...[
            const Gap(8),
            ...widget.variants.asMap().entries.map((entry) {
              final index = entry.key;
              final variant = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    variant['name'] ?? '',
                    style: AppFont.font14W600Black,
                  ),
                  subtitle: Text(
                    (variant['options'] as List?)?.join(', ') ?? '',
                    style: AppFont.font12w400Black,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: AppColor.danger),
                    onPressed: () => _removeVariant(index),
                  ),
                ),
              );
            }),
          ],
          const Gap(16),
          DropdownButtonFormField<String>(
            initialValue: widget.productType,
            style: AppFont.font16W700Black,
            decoration: InputDecoration(
              labelText: 'Product Type'.tr,
              labelStyle: AppFont.labelTextField,
              fillColor: AppColor.primary2,
              filled: true,
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary)),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
            items: ['Physical', 'Digital']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.tr, style: AppFont.font14W500Black),
                    ))
                .toList(),
            onChanged: (value) => widget.onProductTypeChanged(value ?? ''),
          ),
          const Gap(32),
        ],
      ),
    );
  }
}

class _VariantDialog extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onSave;

  const _VariantDialog({required this.onSave});

  @override
  State<_VariantDialog> createState() => _VariantDialogState();
}

class _VariantDialogState extends State<_VariantDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _optionsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      UIHelper.showGlobalSnackBar(
        text: 'Please enter variant name'.tr,
        color: AppColor.danger,
      );
      return;
    }
    if (_optionsController.text.trim().isEmpty) {
      UIHelper.showGlobalSnackBar(
        text: 'Please enter variant options (comma-separated)'.tr,
        color: AppColor.danger,
      );
      return;
    }

    final options = _optionsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    widget.onSave({
      'name': _nameController.text.trim(),
      'options': options,
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Variant'.tr,
        style: AppFont.font18W700Black,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              FocusManager.instance.primaryFocus?.nextFocus();
            },
            decoration: InputDecoration(
              labelText: 'Variant Name (e.g., Color)'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Gap(16),
          TextField(
            controller: _optionsController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              _save();
            },
            decoration: InputDecoration(
              labelText: 'Options (comma-separated)'.tr,
              hintText: 'Example: Black, White, Red'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel'.tr,
            style: AppFont.font14W600Black,
          ),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Save'.tr,
            style: AppFont.font14W600White,
          ),
        ),
      ],
    );
  }
}
