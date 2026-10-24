import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../../../core/service/auth_service.dart';
import '../../../../../core/service/loading_provider.dart';
import '../../../../../core/service/local_data_manager.dart';
import '../../../../../main.dart';
import '../../../../../ui/shared_widgets/custom_filled_button.dart';
import '../../../../../ui/shared_widgets/custom_reactive_form_consumer.dart';
import '../../../../../ui/ui.dart';
import '../../../../../helper/phone_validation_mixin.dart';
import '../../../domain/use_cases/update_profile_use_case.dart';
import '../../manager/update_profile_provider.dart';
import '../../manager/upload_file_notifier.dart';

class EditProfileConfirmButton extends StatelessWidget with PhoneValidationMixin {
  const EditProfileConfirmButton({
    super.key,
    required this.formGroup,
  });

  final FormGroup formGroup;

  @override
  Widget build(BuildContext context) {
    return CustomReactiveFormValidationConsumer(
        formGroup: formGroup,
        builder: (BuildContext context, FormGroup form, Widget? child) {
          return Consumer(
            builder: (BuildContext context, ref, Widget? child) {
              final isLoading = ref.watch(isLoadingProvider("updateProfile"));
              return CustomFilledButton(
                isLoading: isLoading,
                isValid: form.valid,
                onPressed: () async => await _confirmEditProfile(form,ref),
                text: "Save".tr,
              );
            },
          );
        });
  }

  Future<void> _confirmEditProfile(FormGroup form,WidgetRef ref) async {
    final countryCode = form.control('countryCode').value?.toString();
    final localPhone = form.control('phone').value?.toString();
    Map<String, dynamic> requestBody = {
      ...form.value,
      'countryCode': normalizeCountryCode(countryCode),
      'phone': joinPhone(countryCode, localPhone),
    };
    if (form.valid) {
      try {
        ref
            .read(isLoadingProvider("updateProfile").notifier)
            .state = true;
        final selectedFile = ref.read(uploadFileNotifierProvider2("profile"));
        if (selectedFile != null) {
          requestBody = {
            ...requestBody,
            'image': selectedFile,
          };
        } else {
          requestBody = {
            ...requestBody,
            'image': null,
          };
        }
        final res = await getIt<UpdateProfileUseCase>().call(
          requestBody..removeWhere((key, value) => value == null),
        );
        res.fold((l) {
          UIHelper.showAlert(l.message, type: DialogType.error);
        }, (r) async {
          await _rememberPersonalInfo(form);
          UIHelper.showAlert(r.tr);
          await ref.refresh(refreshProfileProvider.future).then((_) {});
          await _rememberPersonalInfo(form);
        });
      } finally {
        ref
            .read(isLoadingProvider("updateProfile").notifier)
            .state = false;
      }
    } else {
      form.markAllAsTouched();
    }
  }

  Future<void> _rememberPersonalInfo(FormGroup form) async {
    final current = dataManager.getUser();
    if (current == null) return;
    final countryCode = form.control('countryCode').value?.toString();
    final localPhone = form.control('phone').value?.toString();
    final updated = current.copyWithPersonal(
      name: form.control('name').value?.toString() ?? current.name,
      bio: form.control('bio').value?.toString() ?? '',
      phone: joinPhone(countryCode, localPhone),
      countryCode: normalizeCountryCode(countryCode),
      email: form.control('email').value?.toString() ?? current.email,
    );
    await dataManager.setUser(updated);
    providerContainer.read(userProvider.notifier).state = updated;
  }
}
