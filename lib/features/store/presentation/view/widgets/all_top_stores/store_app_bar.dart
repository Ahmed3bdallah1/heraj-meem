import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../config/app_color.dart';
import '../../../../../../config/app_font.dart';

class StoreAppBar extends StatelessWidget {
  const StoreAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _BackButton(),
      flexibleSpace: _FlexibleSpaceBar(),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(225),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back,
          color: AppColor.primary,
          size: 20,
        ),
      ),
      onPressed: () => Get.back(),
    );
  }
}

class _FlexibleSpaceBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      title: Text(
        'Best Companies'.tr,
        style: AppFont.font20W700Black.copyWith(
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withAlpha(75),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      centerTitle: true,
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColor.primary.withAlpha(200),
              AppColor.primary.withAlpha(100),
            ],
          ),
        ),
      ),
    );
  }
}

