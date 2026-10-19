part of '../../add_ad_screen.dart';

class _AddAdProgressSegment extends StatelessWidget {
  const _AddAdProgressSegment({
    required this.filled,
    required this.showGap,
  });

  final bool filled;
  final bool showGap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: filled ? AppColor.primary : AppColor.grey1,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (showGap) const Gap(8),
        ],
      ),
    );
  }
}
