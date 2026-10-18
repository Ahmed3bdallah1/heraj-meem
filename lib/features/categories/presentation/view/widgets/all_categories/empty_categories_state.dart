import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../../../config/app_font.dart';

class EmptyCategoriesState extends StatelessWidget {
  const EmptyCategoriesState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const Gap(24),
            Text(
              'No Categories'.tr,
              style: AppFont.font18W700Black,
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'There are no categories available.'.tr,
              style: AppFont.font14W500Black.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

