import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../config/app_font.dart';
import '../../../../../helper/phone_validation_mixin.dart';
import '../../../../../ui/shared_widgets/country_flag.dart';

class CountryCodeButton extends StatelessWidget with PhoneValidationMixin {
  const CountryCodeButton({
    super.key,
    required this.formGroup,
    this.enabled = true,
  });

  final FormGroup formGroup;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<String>(
      formControlName: 'country_code',
      builder: (context, countryCodeControl, child) {
        final raw = countryCodeControl.value ?? '+966';
        final phoneCode = raw.contains('+') ? raw : '+$raw';
        final country = getCountryFromPhoneCode(phoneCode);

        return InkWell(
          onTap: enabled
              ? () {
                  showCountryPicker(
                    context: context,
                    customFlagBuilder: (country) => CountryFlag(country, size: 24),
                    onSelect: (Country selectedCountry) {
                      formGroup.control('country_code').updateValue(
                            '+${selectedCountry.phoneCode}',
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
                          borderSide: BorderSide(color: AppColor.primary2),
                        ),
                      ),
                      searchTextStyle: AppFont.font14W500Black,
                    ),
                  );
                }
              : null,
          child: Container(
            width: 108,
            height: 48,
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColor.grey1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CountryFlag(country),
                const Gap(6),
                Text(
                  country.phoneCode,
                  style: AppFont.font14W500Black.copyWith(height: 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
