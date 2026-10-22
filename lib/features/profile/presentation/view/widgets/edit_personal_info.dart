import 'package:country_picker/country_picker.dart';
import 'package:heraj_meem/helper/responsive.dart';
import 'package:heraj_meem/helper/phone_validation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../../config/app_color.dart';
import '../../../../../../ui/shared_widgets/custom_text_field.dart';
import '../../../../../config/app_font.dart';

class EditPersonalInfo extends ConsumerWidget {
  const EditPersonalInfo({
    super.key,
    required this.formGroup,
    required this.phoneValidationMixin,
    required this.nameFocus,
    required this.phoneFocus,
    required this.emailFocus,
    required this.bioFocus,
  });

  final FormGroup formGroup;
  final PhoneValidationMixin phoneValidationMixin;
  final FocusNode nameFocus;
  final FocusNode phoneFocus;
  final FocusNode emailFocus;
  final FocusNode bioFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(10),
        CustomTextField(
          formControlName: "name",
          labelText: "name".tr,
          borderRadius: BorderRadius.circular(12),
          focusNode: nameFocus,
          textInputAction: TextInputAction.next,
        ),
        const Gap(12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: CustomTextField(
                formControlName: "phone",
                hintText: "phone".tr,
                labelText: "phone".tr,
                inputType: TextInputType.phone,
                focusNode: phoneFocus,
                textInputAction: TextInputAction.next,
              ),
            ),
            const Gap(10),
            Expanded(
              flex: 2,
              child: ReactiveValueListenableBuilder<String>(
                formControlName: 'countryCode',
                builder: (context, countryCodeControl, child) {
                  final phoneCode =
                      (!(countryCodeControl.value?.contains("+") ?? false)
                              ? '+${countryCodeControl.value}'
                              : countryCodeControl.value) ??
                          '+20';
                  final country =
                      phoneValidationMixin.getCountryFromPhoneCode(phoneCode);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "code".tr,
                        style: AppFont.font14W500Black,
                        textAlign: TextAlign.start,
                      ),
                      Gap(10.h),
                      InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            onSelect: (Country selectedCountry) {
                              final code = selectedCountry.phoneCode;
                              formGroup.control('countryCode').updateValue(
                                    code.startsWith('+') ? code : '+$code',
                                    emitEvent: true,
                                  );
                            },
                            countryListTheme: CountryListThemeData(
                              flagSize: 24,
                              backgroundColor: Colors.white,
                              textStyle: AppFont.font14W500Black,
                              inputDecoration: InputDecoration(
                                labelText: 'Search'.tr,
                                hintText: 'Start typing to search'.tr,
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColor.grey1,
                                  ),
                                ),
                              ),
                              searchTextStyle: AppFont.font14W500Black,
                            ),
                          );
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColor.grey1,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColor.grey1),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                country.flagEmoji,
                                style: AppFont.font20W700Black,
                              ),
                              const Gap(6),
                              Flexible(
                                child: Text(
                                  country.phoneCode.startsWith('+')
                                      ? country.phoneCode
                                      : '+${country.phoneCode}',
                                  style: AppFont.font14W500Black,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const Gap(12),
        CustomTextField(
          formControlName: "email",
          labelText: "Email".tr,
          focusNode: emailFocus,
          textInputAction: TextInputAction.next,
          inputType: TextInputType.emailAddress,
        ),
        const Gap(12),
        CustomTextField(
          formControlName: "bio",
          labelText: "Bio".tr,
          hintText: "Bio".tr,
          focusNode: bioFocus,
          textInputAction: TextInputAction.done,
          maxLines: 4,
          maxHeight: 120,
          inputType: TextInputType.multiline,
        ),
        const Gap(50),
      ],
    );
  }
}
