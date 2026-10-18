import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import '../../../../../../config/app_font.dart';

class EmptyStoresState extends StatelessWidget {
  const EmptyStoresState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const Gap(24),
            Text(
              'No stores found'.tr,
              style: AppFont.font18W700Black,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

