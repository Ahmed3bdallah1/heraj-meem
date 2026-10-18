import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color.dart';

ThemeData getLightTheme() {
  return FlexThemeData.light(
      scaffoldBackground: Color(0xffF4F4F4),
      appBarStyle: FlexAppBarStyle.background,
      colors: const FlexSchemeColor(
        primary: AppColor.primary,
        secondary: Colors.white,
      ),
      primaryTextTheme: GoogleFonts.readexProTextTheme(),
      scheme: FlexScheme.greenM3,
      textTheme: GoogleFonts.readexProTextTheme(),
      fontFamily: GoogleFonts.readexPro().fontFamily,
      primary: AppColor.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColor.primary,
        secondary: AppColor.primary,
      ));
}

ThemeData getDarkTheme() {
  Color mainColor = AppColor.primaryWhite;

  return FlexThemeData.dark(
      scaffoldBackground: const Color(0xff151518),
      appBarStyle: FlexAppBarStyle.scaffoldBackground,
      colors: const FlexSchemeColor(
        primary: AppColor.primary,
        secondary: Colors.white,
      ),
      primaryTextTheme: GoogleFonts.manropeTextTheme(),
      scheme: FlexScheme.greenM3,
      textTheme: GoogleFonts.manropeTextTheme(),
      fontFamily: GoogleFonts.manrope().fontFamily,
      primary: AppColor.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColor.primary,
        secondary: AppColor.primary,
      )
      // textButtonTheme: TextButtonThemeData(
      //   style: TextButton.styleFrom(foregroundColor: mainColor),
      // ),
      // colorScheme: ColorScheme.dark(
      //   primary: mainColor,
      //   secondary: mainColor,
      // )
      );
}
