import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class AppColor {
  static Color get white =>
      Get.isDarkMode ? const Color(0xff151518) : Colors.white;

  static Color get nearlyWhite =>
      Get.isDarkMode ? const Color(0xff283046) : Colors.white;

  static Color get grey3 =>
      Get.isDarkMode ? const Color(0xff777777) : Colors.white;

  static Color get grey_3 =>
      Get.isDarkMode ? const Color(0xff929898) : const Color(0xffD9D9D9);

  static Color get gray_3 =>
      Get.isDarkMode ? const Color(0xff777777) : const Color(0xffD9D9D9);

  static Color get whiteOrGrey =>
      Get.isDarkMode ? const Color(0xff929898) : Colors.white;

  static Color get black =>
      Get.isDarkMode ? Colors.white : const Color(0xff161d31);
  static const Color green = Color(0xff00A991);
  static const Color green1 = Color(0xff29CD00);
  static Color danger = const Color(0xffE34E00);
  static Color danger2 = Get.isDarkMode ? Colors.red.shade900 : Colors.red;
  static Color orange = Colors.orange;
  static Color gold = Color(0xffFFFF00);
  static const Color primary = Color(0xffF39200);
  static final Color primaryWhite2 = primary.withAlpha(40);
  static Color primaryWhite =
      Get.isDarkMode ? const Color(0xff161d31) : const Color(0xffF0EBEB);
  static const Color primary2 = Color(0xffF5F0E8);
  static const Color primary3 = Color(0xffE9E1E1);
  static const Color primary4 = Color(0xff241180);
  static const Color primary5 = Color(0xffB9C3CF);
  static const Color mineShaft = Color(0xff222222);

  static Color get shipmentTileColor =>
      Get.isDarkMode ? const Color(0xff2f2f2f) : Colors.white;

  static const Color primaryDark = Color(0xff2EC1D1);

  static Color get backGround =>
      Get.isDarkMode ? const Color(0xff303030) : const Color(0xffEAEAEA);

  static Color get disabled =>
      Get.isDarkMode ? const Color(0xff9EACAD) : const Color(0xffC0CDCE);

  static Color get grey2 =>
      Get.isDarkMode ? const Color(0xff929898) : const Color(0xff656969);

  static Color get grey1 => const Color(0xffd0d9e5);
  static const unselectedNavBar = Color(0xff707070);

  static BoxShadow defaultShadow = BoxShadow(
      color: Colors.black.withAlpha(40),
      offset: Offset(0, 3),
      blurRadius: 8,
      spreadRadius: 0);

  static BoxShadow lightShadow = BoxShadow(
      color: Colors.grey.withAlpha(120),
      offset: Offset(0, 3),
      blurRadius: 8,
      spreadRadius: 0);

  static BoxShadow defaultPrimaryShadow = BoxShadow(
    color: AppColor.primary.withAlpha(50),
    blurRadius: 6,
    spreadRadius: 5,
    offset: const Offset(0, 3),
  );

  static LinearGradient defaultPrimaryGradient = LinearGradient(
    colors: [AppColor.primary, Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
