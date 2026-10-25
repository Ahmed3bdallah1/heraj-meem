import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../config/app_font.dart';
import '../../helper/responsive.dart';

enum TextFieldType { text, selectable }

class CustomTextField<T> extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.hintText,
    this.formControlName,
    this.autofillHints,
    this.radius = 25,
    this.inputType = TextInputType.text,
    this.style = 1,
    this.inputFormatter,
    this.paddingFromTop = false,
    this.onEditDone,
    this.onTap,
    this.obscure = false,
    this.maxLines = 1,
    this.control,
    this.iconDataPrefix,
    this.iconColor = Colors.grey,
    this.iconButton,
    this.type = TextFieldType.text,
    this.items,
    this.onChanged,
    this.borderRadius,
    this.hideSelectableIconIfIgnore = true,
    this.ignore = false,
    this.labelText,
    this.prefixText,
    this.suffixText,
    this.focusNode,
    this.textInputAction,
  });

  final Iterable<String>? autofillHints;
  final String? formControlName;
  final FormControl<T>? control;
  final String? hintText;
  final String? labelText;
  final FocusNode? focusNode;
  final int style;
  final Widget? iconButton;
  final bool obscure;
  final bool ignore;
  final double radius;
  final int maxLines;
  final VoidCallback? onEditDone;
  final bool paddingFromTop;
  final List<TextInputFormatter>? inputFormatter;
  final TextInputType inputType;
  final void Function()? onTap;
  final TextFieldType type;
  final List<DropdownMenuItem<T>>? items;
  final String? prefixText;
  final String? suffixText;
  final Widget? iconDataPrefix;
  final Color iconColor;
  final ReactiveFormFieldCallback<T>? onChanged;
  final BorderRadius? borderRadius;
  final bool hideSelectableIconIfIgnore;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final validation = {
      ValidationMessage.email: (controller) => ValidationMessage.email.tr,
      ValidationMessage.required: (controller) => ValidationMessage.required.tr,
      ValidationMessage.number: (controller) => ValidationMessage.number.tr,
      ValidationMessage.minLength: (controller) =>
          ValidationMessage.minLength.tr,
      ValidationMessage.maxLength: (controller) =>
          ValidationMessage.maxLength.tr,
      ValidationMessage.mustMatch: (controller) =>
          ValidationMessage.mustMatch.tr,
    };
    final InputDecoration decoration = InputDecoration(
      isDense: false,
      contentPadding: EdgeInsetsDirectional.only(
        start: 16,
        end: 16,
        top: maxLines == 1 ? 0 : 12,
        bottom: maxLines == 1 ? 0 : 12,
      ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 48,
      ),
      labelStyle: AppFont.labelTextField,
      filled: true,
      fillColor: AppColor.white,
      suffixIcon: iconButton,
      prefixIcon: iconDataPrefix,
      hintText: hintText,
      prefixText: prefixText,
      suffixText: suffixText,
      prefixStyle: AppFont.textFiled,
      suffixStyle: AppFont.textFiled,
      hintStyle: AppFont.hintTextField.copyWith(height: 1.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: const BorderSide(color: AppColor.primary),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(color: AppColor.grey1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(color: AppColor.grey1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: const BorderSide(color: AppColor.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(color: AppColor.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(color: AppColor.danger, width: 1.5),
      ),
      errorStyle: AppFont.font12w400Black.copyWith(
        color: AppColor.danger,
        height: 1.2,
      ),
      errorMaxLines: 2,
    );
    final wid = type == TextFieldType.text
        ? ReactiveTextField<T>(
            autofillHints: autofillHints,
            contextMenuBuilder: (context, editableTextState) {
              final items = editableTextState.contextMenuButtonItems;
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: items,
              );
            },
            // onTapOutside: (controller) {
            //   FocusManager.instance.primaryFocus?.unfocus();
            // },
            textInputAction: textInputAction ??
                (inputType == TextInputType.multiline
                    ? TextInputAction.newline
                    : TextInputAction.next),
            formControl: control,
            onSubmitted: (controller) {
              if (focusNode != null) {
                focusNode!.nextFocus();
              } else {
                FocusManager.instance.primaryFocus?.nextFocus();
              }
            },
            onEditingComplete: (controller) {
              if (focusNode != null) {
                focusNode!.nextFocus();
              } else {
                FocusManager.instance.primaryFocus?.nextFocus();
              }
              onEditDone?.call();
            },
            onTap: onTap == null
                ? null
                : (controller) {
                    onTap!.call();
                  },
            keyboardType: inputType,
            maxLines: maxLines,
            inputFormatters: [
              ...?inputFormatter,
              if (inputType == TextInputType.phone)
                FilteringTextInputFormatter.digitsOnly
            ],
            obscureText: obscure,
            style: AppFont.textFiled,
            textAlignVertical: maxLines == 1
                ? TextAlignVertical.center
                : TextAlignVertical.top,
            formControlName: formControlName,
            decoration: decoration,
            validationMessages: validation,
            onChanged: onChanged,
          )
        : ReactiveDropdownField<T>(
            iconEnabledColor: AppColor.primary,
            iconDisabledColor: AppColor.disabled,
            itemHeight: kMinInteractiveDimension,
            isDense: false,
            icon: ignore && hideSelectableIconIfIgnore
                ? const SizedBox.shrink()
                : null,
            formControl: formControlName != null ? null : control,
            onTap: onTap == null
                ? null
                : (controller) {
                    onTap!.call();
                  },
            onChanged: onChanged,
            style: AppFont.textFiled,
            formControlName: formControlName,
            decoration: decoration,
            items: items!,
            validationMessages: validation,
          );
    return Column(
      children: [
        if (labelText != null)
          Column(
            children: [
              Align(
                alignment: const AlignmentDirectional(-1, 0),
                child: Text(
                  labelText!,
                  style: AppFont.font14W500Black,
                  textAlign: TextAlign.start,
                ),
              ),
              Gap(10),
            ],
          ),
        InkWell(
          onTap: ignore ? onTap : null,
          child: IgnorePointer(
            ignoring: ignore,
            child: wid,
          ),
        ),
      ],
    );
  }
}
