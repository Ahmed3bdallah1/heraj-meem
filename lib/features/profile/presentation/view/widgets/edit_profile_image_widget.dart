import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../../../config/app_color.dart';
import '../../../../../core/service/auth_service.dart';
import '../../../../../core/service/loading_provider.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../../../ui/shared_widgets/loading_widget.dart';
import '../../manager/upload_file_notifier.dart';

class EditProfileImageWidget extends StatelessWidget {
  const EditProfileImageWidget({
    super.key,
    required this.ref,
    required this.formGroup,
  });

  final WidgetRef ref;
  final FormGroup formGroup;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(200),
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Consumer(
              builder: (context, ref, child) {
                final selectedFile = ref.watch(uploadFileNotifierProvider);
                final userImageUrl =
                    ref.watch(userProvider.select((user) => user?.image));
                final isLoadingPick = ref.watch(isLoadingProvider("setImage"));

                if (isLoadingPick) {
                  return const SizedBox(
                    width: 120,
                    height: 120,
                    child: Center(child: LoadingWidget()),
                  );
                }

                if (selectedFile != null) {
                  return ImageOrSvg(
                    selectedFile,
                    fit: BoxFit.cover,
                    height: 120,
                    width: 120,
                  );
                }

                return ImageOrSvg(
                  userImageUrl,
                  fit: BoxFit.cover,
                  height: 120,
                  width: 120,
                  isLocal: false,
                  pickImageOnNull: true,
                  assetImageOnNull: Assets.base.profile.path,
                  isLoading: false,
                  magnifier: true,
                );
              },
            ),
          ),
        ),
        Positioned.directional(
            bottom: 10,
            start: 0,
            textDirection: TextDirection.rtl,
            child: InkWell(
              onTap: () async {
                final newImageProvider =
                    ref.read(uploadFileNotifierProvider.notifier);
                final image = await newImageProvider.pickImage();
                if (image != null) {
                  try {
                    ref.read(isLoadingProvider("setImage").notifier).state =
                        true;

                    final uploaded = await newImageProvider.uploadFile(image);
                    formGroup.control('avatar').value = uploaded;
                  } finally {
                    ref.read(isLoadingProvider("setImage").notifier).state =
                        false;
                  }
                }
              },
              child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.primary, width: 2)),
                child: const Icon(
                  FontAwesomeIcons.pen,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ))
      ],
    );
  }
}
