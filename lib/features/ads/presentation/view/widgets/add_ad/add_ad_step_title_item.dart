part of '../../add_ad_screen.dart';

class _AddAdStepTitle extends StatelessWidget {
  const _AddAdStepTitle({
    required this.index,
    required this.filled,
  });

  final int index;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final title = switch (index) {
      0 => 'Select City'.tr,
      1 => 'Select Category'.tr,
      2 => 'Ad Details'.tr,
      _ => 'Ad Pending'.tr,
    };
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: filled ? AppColor.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: filled ? AppColor.primary : AppColor.grey1,
                width: 2,
              ),
            ),
            child: filled
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          const Gap(4),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFont.font10w400Black.copyWith(
                color: filled ? AppColor.primary : AppColor.grey2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
