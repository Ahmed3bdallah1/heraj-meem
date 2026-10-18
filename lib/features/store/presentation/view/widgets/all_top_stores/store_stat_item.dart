import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../../../../config/app_font.dart';

class StoreStatItem extends StatelessWidget {
  final String value;
  final String label;

  const StoreStatItem({
    super.key,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppFont.font14W700Black.copyWith(
            color: AppColor.primary,
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: AppFont.font12w400Black.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

