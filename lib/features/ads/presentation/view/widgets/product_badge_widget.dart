 import 'package:flutter/material.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/localization_service/localization_service.dart';
import 'package:heraj_meem/features/ads/data/models/product_details_model.dart';
import 'package:heraj_meem/main.dart';

class ProductBadgeWidget extends StatefulWidget {
  final BadgeModel badge;

  const ProductBadgeWidget({
    super.key,
    required this.badge,
  });

  @override
  State<ProductBadgeWidget> createState() => _ProductBadgeWidgetState();
}

class _ProductBadgeWidgetState extends State<ProductBadgeWidget> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _translateAnimation;
  Animation<double>? _shimmerAnimation;
  String? _animationType;

  @override
  void initState() {
    super.initState();

    _animationType = widget.badge.animationType?.toLowerCase();

    if (_animationType == 'pulse' ||
        _animationType == 'bounce' ||
        _animationType == 'shimmer') {
      _animationController = AnimationController(
        vsync: this,
        duration: _animationType == 'pulse'
            ? const Duration(milliseconds: 1000)
            : _animationType == 'bounce'
                ? const Duration(milliseconds: 800)
                : const Duration(milliseconds: 1500),
      )..repeat(reverse: _animationType == 'shimmer');

      final controller = _animationController!;

      if (_animationType == 'pulse') {
        _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.easeInOut,
          ),
        );
      } else if (_animationType == 'bounce') {
        _scaleAnimation = Tween<double>(begin: 1, end: 1.1).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.elasticOut,
          ),
        );
        _translateAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.elasticOut,
          ),
        );
      } else if (_animationType == 'shimmer') {
        _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Curves.linear,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.transparent;
    }
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      return Colors.transparent;
    }
    return Colors.transparent;
  }

  String _getBadgeText() {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    if (langCode == "ar") {
      return widget.badge.textAr ?? widget.badge.text;
    } else if (langCode == "tr") {
      return widget.badge.textTr ?? widget.badge.text;
    }
    return widget.badge.text;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.badge.isActive) {
      return const SizedBox.shrink();
    }

    final backgroundColor = _parseColor(widget.badge.backgroundColor);
    final textColor = _parseColor(widget.badge.textColor);
    final borderColor = _parseColor(widget.badge.borderColor);

    Widget badgeContent = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withAlpha(25),
              blurRadius: 4,
              spreadRadius: 6,
            ),
          ],
          border: borderColor != Colors.transparent
              ? Border.all(color: borderColor, width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.badge.icon != null && widget.badge.icon!.isNotEmpty) ...[
              const SizedBox(width: 4),
            ],
            Text(
              _getBadgeText(),
              style: AppFont.font12W600Black.copyWith(
                color:
                    textColor != Colors.transparent ? textColor : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    if (_animationType == 'pulse' && _scaleAnimation != null) {
      return AnimatedBuilder(
        animation: _scaleAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation!.value,
            child: badgeContent,
          );
        },
      );
    }

    if (_animationType == 'bounce' &&
        _animationController != null &&
        _scaleAnimation != null &&
        _translateAnimation != null) {
      return AnimatedBuilder(
        animation: _animationController!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _translateAnimation!.value),
            child: Transform.scale(
              scale: _scaleAnimation!.value,
              child: badgeContent,
            ),
          );
        },
      );
    }

    if (_animationType == 'shimmer' &&
        _animationController != null &&
        _shimmerAnimation != null) {
      return AnimatedBuilder(
        animation: _shimmerAnimation!,
        builder: (context, child) {
          final shimmerValue = _shimmerAnimation!.value;

          return ShaderMask(
            shaderCallback: (bounds) {
              final width = bounds.width;
              final shimmerWidth = width * 0.3;
              final shimmerStart = (shimmerValue + 1.0) * width - shimmerWidth;
              final shimmerEnd = shimmerStart + shimmerWidth;

              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.white.withAlpha(150),
                  Colors.white.withAlpha(150),
                  Colors.transparent,
                ],
                stops: [
                  0.0,
                  (shimmerStart / width).clamp(0.0, 1.0),
                  (shimmerEnd / width).clamp(0.0, 1.0),
                  1.0,
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: badgeContent,
          );
        },
      );
    }

    return badgeContent;
  }
}

class ProductBadgesList extends StatelessWidget {
  final List<BadgeModel> badges;

  const ProductBadgesList({
    super.key,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    final activeBadges = badges.where((badge) => badge.isActive).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (activeBadges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: activeBadges.reversed
          .map((badge) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProductBadgeWidget(badge: badge),
              ))
          .toList(),
    );
  }
}
