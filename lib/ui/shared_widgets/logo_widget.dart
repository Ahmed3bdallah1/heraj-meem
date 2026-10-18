import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_color.dart';
import '../../gen/assets.gen.dart';
import '../../helper/responsive.dart';
import 'image_or_svg.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({
    this.colorText,
    this.colorImage,
    super.key,
  });

  final Color? colorText;
  final Color? colorImage;

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    return Image.asset(
      Assets.base.logo.path,
      height: 150,
    );
  }
}
