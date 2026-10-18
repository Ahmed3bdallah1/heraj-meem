import 'dart:ui';

enum Language {
  turkish(Locale('tr', 'TR'), 'assets/base/turkia.png'),
  english(Locale('en', 'US'), 'assets/base/england.svg'),
  arabic(Locale('ar', 'US'), 'assets/base/egypt.svg');

  final Locale locale;
  final String flag;

   const Language(this.locale,this.flag);
}

