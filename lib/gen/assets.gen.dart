// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsBaseGen {
  const $AssetsBaseGen();

  /// File path: assets/base/Logo.png
  AssetGenImage get logo => const AssetGenImage('assets/base/Logo.png');

  /// File path: assets/base/egypt.svg
  String get egypt => 'assets/base/egypt.svg';

  /// File path: assets/base/england.svg
  String get england => 'assets/base/england.svg';

  /// File path: assets/base/error.png
  AssetGenImage get error => const AssetGenImage('assets/base/error.png');

  /// File path: assets/base/eye-crossed.svg
  String get eyeCrossed => 'assets/base/eye-crossed.svg';

  /// File path: assets/base/eye.svg
  String get eye => 'assets/base/eye.svg';

  /// File path: assets/base/folder-open-svgrepo-com.svg
  String get folderOpenSvgrepoCom => 'assets/base/folder-open-svgrepo-com.svg';

  /// File path: assets/base/get_started1.jpg
  AssetGenImage get getStarted1 =>
      const AssetGenImage('assets/base/get_started1.jpg');

  /// File path: assets/base/get_started2.jpg
  AssetGenImage get getStarted2 =>
      const AssetGenImage('assets/base/get_started2.jpg');

  /// File path: assets/base/loading.gif
  AssetGenImage get loading => const AssetGenImage('assets/base/loading.gif');

  /// File path: assets/base/location.png
  AssetGenImage get location => const AssetGenImage('assets/base/location.png');

  /// File path: assets/base/logo_splash.png
  AssetGenImage get logoSplash =>
      const AssetGenImage('assets/base/logo_splash.png');

  /// File path: assets/base/logo_white.png
  AssetGenImage get logoWhite =>
      const AssetGenImage('assets/base/logo_white.png');

  /// File path: assets/base/no_wifi.json
  String get noWifi => 'assets/base/no_wifi.json';

  /// File path: assets/base/not-found.json
  String get notFound => 'assets/base/not-found.json';

  /// File path: assets/base/on1.jpg
  AssetGenImage get on1 => const AssetGenImage('assets/base/on1.jpg');

  /// File path: assets/base/on2.jpg
  AssetGenImage get on2 => const AssetGenImage('assets/base/on2.jpg');

  /// File path: assets/base/on3.jpg
  AssetGenImage get on3 => const AssetGenImage('assets/base/on3.jpg');

  /// File path: assets/base/profile.png
  AssetGenImage get profile => const AssetGenImage('assets/base/profile.png');

  /// File path: assets/base/search.svg
  String get search => 'assets/base/search.svg';

  /// File path: assets/base/security.png
  AssetGenImage get security => const AssetGenImage('assets/base/security.png');

  /// File path: assets/base/spain.svg
  String get spain => 'assets/base/spain.svg';

  /// File path: assets/base/turkia.png
  AssetGenImage get turkia => const AssetGenImage('assets/base/turkia.png');

  /// File path: assets/base/visa.png
  AssetGenImage get visa => const AssetGenImage('assets/base/visa.png');

  /// List of all assets
  List<dynamic> get values => [
        logo,
        egypt,
        england,
        error,
        eyeCrossed,
        eye,
        folderOpenSvgrepoCom,
        getStarted1,
        getStarted2,
        loading,
        location,
        logoSplash,
        logoWhite,
        noWifi,
        notFound,
        on1,
        on2,
        on3,
        profile,
        search,
        security,
        spain,
        turkia,
        visa
      ];
}

class $AssetsSocialMediaGen {
  const $AssetsSocialMediaGen();

  /// File path: assets/social_media/apple.png
  AssetGenImage get apple =>
      const AssetGenImage('assets/social_media/apple.png');

  /// File path: assets/social_media/error_404_outdoor.lottie
  String get error404Outdoor => 'assets/social_media/error_404_outdoor.lottie';

  /// File path: assets/social_media/gmail.png
  AssetGenImage get gmail =>
      const AssetGenImage('assets/social_media/gmail.png');

  /// File path: assets/social_media/profile-circle.svg
  String get profileCircle => 'assets/social_media/profile-circle.svg';

  /// List of all assets
  List<dynamic> get values => [apple, error404Outdoor, gmail, profileCircle];
}

class Assets {
  const Assets._();

  static const $AssetsBaseGen base = $AssetsBaseGen();
  static const $AssetsSocialMediaGen socialMedia = $AssetsSocialMediaGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
