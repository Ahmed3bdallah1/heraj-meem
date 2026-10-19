import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/home/presentation/view/widgets/home_entrance.dart';

class HomePhotosFilterComponent extends ConsumerWidget {
  const HomePhotosFilterComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosOnly = ref.watch(photosOnlyProvider);
    return HomeEntrance(
      index: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Ads with photos only'.tr,
                style: AppFont.font14W500Black,
              ),
            ),
            Switch(
              value: photosOnly,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColor.primary,
              onChanged: (value) =>
                  ref.read(photosOnlyProvider.notifier).state = value,
            ),
          ],
        ),
      ),
    );
  }
}
