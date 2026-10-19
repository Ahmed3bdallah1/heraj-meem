part of '../../add_ad_screen.dart';

class _AddAdCheckMark extends StatelessWidget {
  const _AddAdCheckMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColor.primary : AppColor.grey1,
          width: 2,
        ),
        color: selected ? AppColor.primary : Colors.transparent,
      ),
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : null,
    );
  }
}
