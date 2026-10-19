part of '../../add_ad_screen.dart';

class _AddAdPendingStep extends StatelessWidget {
  const _AddAdPendingStep({
    required this.createdAdId,
    required this.onViewAd,
    required this.onGoHome,
  });

  final ValueNotifier<String?> createdAdId;
  final VoidCallback onViewAd;
  final VoidCallback onGoHome;

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
                return Row(
                  children: [
                    Expanded(
                      child: CustomFilledButton(
                        text: 'View My Ad'.tr,
                        onPressed:
                            adId == null || adId.isEmpty ? null : onViewAd,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: CustomOutlinedButton(
                        text: 'Go To Home'.tr,
                        textColor: AppColor.primary,
                        onPressed: onGoHome,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
