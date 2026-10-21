part of '../../add_ad_screen.dart';

class _AddAdAttributes extends StatelessWidget {
  const _AddAdAttributes({
    required this.focus,
    required this.onAdd,
    required this.onRemove,
  });

  final List<AddAdAttributeFocus> focus;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attributes'.tr, style: AppFont.font14W700Black),
        const Gap(8),
        ReactiveFormArray<Map<String, Object?>>(
          formArrayName: 'attributes',
          builder: (context, array, _) {
            return Column(
              children: [
                for (var index = 0; index < array.controls.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ReactiveForm(
                      formGroup: array.controls[index] as FormGroup,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ReactiveTextField<String>(
                              formControlName: 'name',
                              focusNode: focus[index].name,
                              textInputAction: TextInputAction.next,
                              style: AppFont.font14W500Black,
                              onSubmitted: (_) =>
                                  focus[index].value.requestFocus(),
                              decoration: _decoration('Attribute name'.tr),
                            ),
                          ),
                          const Gap(8),
                          Expanded(
                            child: ReactiveTextField<String>(
                              formControlName: 'value',
                              focusNode: focus[index].value,
                              textInputAction: index == array.controls.length - 1
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              style: AppFont.font14W500Black,
                              onSubmitted: (_) {
                                if (index < focus.length - 1) {
                                  focus[index + 1].name.requestFocus();
                                } else {
                                  focus[index].value.unfocus();
                                }
                              },
                              decoration: _decoration('Attribute value'.tr),
                            ),
                          ),
                          IconButton(
                            onPressed: () => onRemove(index),
                            icon: Icon(Icons.close, color: AppColor.grey2),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: Icon(Icons.add, color: AppColor.primary),
          label: Text('Add attribute'.tr, style: AppFont.font14W600Primary),
        ),
      ],
    );
  }

  InputDecoration _decoration(String label) {
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
