part of '../../add_ad_screen.dart';

class _AddAdDetailsStep extends StatelessWidget {
  const _AddAdDetailsStep({
    required this.photos,
    required this.showPhone,
    required this.titleFocus,
    required this.priceFocus,
    required this.descriptionFocus,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.attributeFocus,
    required this.onAddAttribute,
    required this.onRemoveAttribute,
  });

  final ValueNotifier<List<AddAdPhoto>> photos;
  final ValueNotifier<bool> showPhone;
  final FocusNode titleFocus;
  final FocusNode priceFocus;
  final FocusNode descriptionFocus;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;
  final List<AddAdAttributeFocus> attributeFocus;
  final VoidCallback onAddAttribute;
  final ValueChanged<int> onRemoveAttribute;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _AddAdPhotoBox(photos: photos, onRemoveImage: onRemoveImage),
        TextButton.icon(
          onPressed: onPickImages,
          icon: Icon(Icons.add_photo_alternate, color: AppColor.primary),
          label: Text('Add Photos'.tr, style: AppFont.font14W600Primary),
        ),
        const Gap(16),
        ReactiveTextField<String>(
          formControlName: 'title',
          focusNode: titleFocus,
          textInputAction: TextInputAction.next,
          style: AppFont.font16W700Black,
          onSubmitted: (_) => priceFocus.requestFocus(),
          decoration: _fieldDecoration('Ad Title'.tr),
        ),
        const Gap(16),
        ReactiveTextField<String>(
          formControlName: 'price',
          focusNode: priceFocus,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          style: AppFont.font16W700Black,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) => descriptionFocus.requestFocus(),
          decoration: _fieldDecoration('Price'.tr),
        ),
        const Gap(16),
        Text('Product Description'.tr, style: AppFont.font14W700Black),
        const Gap(8),
        ReactiveTextField<String>(
          formControlName: 'description',
          focusNode: descriptionFocus,
          textInputAction: TextInputAction.done,
          minLines: 4,
          maxLines: 6,
          style: AppFont.font14W500Black,
          decoration: _fieldDecoration('Enter product description here...'.tr),
        ),
        const Gap(16),
        _AddAdAttributes(
          focus: attributeFocus,
          onAdd: onAddAttribute,
          onRemove: onRemoveAttribute,
        ),
        const Gap(16),
        ValueListenableBuilder<bool>(
          valueListenable: showPhone,
          builder: (context, value, _) {
            return Row(
              children: [
                Expanded(
                  child: Text('Show phone'.tr, style: AppFont.font14W600Black),
                ),
                Switch(
                  value: value,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColor.primary,
                  onChanged: (next) => showPhone.value = next,
                ),
              ],
            );
          },
        ),
        const Gap(32),
      ],
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppFont.labelTextField,
      fillColor: AppColor.primary2,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.primary),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.primary),
      ),
    );
  }
}
