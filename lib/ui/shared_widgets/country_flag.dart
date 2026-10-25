import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

/// Flag emoji must not inherit the app font. A custom font breaks the
/// regional-indicator ligature on iOS and every flag renders as Egypt.
class CountryFlag extends StatelessWidget {
  const CountryFlag(
    this.country, {
    super.key,
    this.size = 22,
  });

  final Country country;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      country.flagEmoji,
      style: TextStyle(
        inherit: false,
        fontSize: size,
        height: 1,
        fontFamily: 'Apple Color Emoji',
        fontFamilyFallback: const [
          'Noto Color Emoji',
          'Segoe UI Emoji',
          'Android Emoji',
        ],
      ),
    );
  }
}
