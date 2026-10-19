import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../config/app_color.dart';
import '../../../../../../config/app_font.dart';

class ProductsAppBar extends StatelessWidget {
  final String title;
  final Color? primaryColor;

  const ProductsAppBar({
    super.key,
    required this.title,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _BackButton(primaryColor: primaryColor),
      flexibleSpace: _FlexibleSpaceBar(title: title, primaryColor: primaryColor),
    );
  }
}

class _BackButton extends StatelessWidget {
  final Color? primaryColor;

  const _BackButton({this.primaryColor});

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? AppColor.primary;
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(225),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back,
          color: color,
          size: 20,
        ),
      ),
      onPressed: () => Get.back(),
    );
  }
}

class _FlexibleSpaceBar extends StatelessWidget {
  final String title;
  final Color? primaryColor;

  const _FlexibleSpaceBar({
    required this.title,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? AppColor.primary;
    return FlexibleSpaceBar(
      title: Text(
        title,
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
              color.withAlpha(200),
              color.withAlpha(100),
            ],
          ),
        ),
      ),
    );
  }
}

