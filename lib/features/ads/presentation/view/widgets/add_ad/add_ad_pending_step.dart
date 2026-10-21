part of '../../add_ad_screen.dart';

class _AddAdPendingStep extends StatelessWidget {
  const _AddAdPendingStep({
    required this.createdAdId,
    required this.publishing,
    required this.onViewAd,
    required this.onPublish,
  });

  final ValueNotifier<String?> createdAdId;
  final ValueNotifier<bool> publishing;
  final VoidCallback onViewAd;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 120, color: AppColor.primary),
            const Gap(32),
            Text(
              'Your new ad has been successfully uploaded'.tr,
              style: AppFont.font18W700Black,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'Please wait for approval'.tr,
              style: AppFont.font14W600Black.copyWith(color: AppColor.grey2),
              textAlign: TextAlign.center,
            ),
            const Gap(48),
            ValueListenableBuilder<String?>(
              valueListenable: createdAdId,
              builder: (context, adId, _) {
                final canAct = adId != null && adId.isNotEmpty;
                return ValueListenableBuilder<bool>(
                  valueListenable: publishing,
                  builder: (context, isPublishing, _) {
                    return Column(
                      children: [
                        CustomOutlinedButton(
                          text: 'Leave it draft & view it'.tr,
                          textColor: AppColor.primary,
                          onPressed: !canAct || isPublishing ? null : onViewAd,
                        ),
                        const Gap(12),
                        CustomFilledButton(
                          text: 'Publish the ad'.tr,
                          isLoading: isPublishing,
                          onPressed: !canAct || isPublishing ? null : onPublish,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
