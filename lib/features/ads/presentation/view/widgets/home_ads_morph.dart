import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/core/service/localization_service/localization_service.dart';
import 'package:heraj_meem/features/ads/data/models/product_model.dart';
import 'package:heraj_meem/features/ads/presentation/view/ad_details_screen.dart';
import 'package:heraj_meem/features/ads/presentation/view/widgets/product_tile.dart';
import 'package:heraj_meem/features/favorites/presentation/managers/favorites.dart';
import 'package:heraj_meem/features/favorites/presentation/view/widgets/favorite_button.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj_meem/ui/shared_widgets/loading_widget.dart';
import 'package:heraj_meem/ui/shared_widgets/price_widget.dart';
import 'package:share_plus/share_plus.dart';

class HomeAdsViewSwitcher extends StatelessWidget {
  const HomeAdsViewSwitcher({
    super.key,
    required this.t,
    required this.onGrid,
    required this.onList,
  });

  final double t;
  final VoidCallback onGrid;
  final VoidCallback onList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xffF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              Align(
                alignment: AlignmentDirectional.lerp(
                  AlignmentDirectional.centerStart,
                  AlignmentDirectional.centerEnd,
                  t,
                )!,
                child: const FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _ViewModeButton(
                      icon: Icons.grid_view_rounded,
                      tooltip: 'Grid view'.tr,
                      amount: 1 - t,
                      onTap: onGrid,
                    ),
                  ),
                  Expanded(
                    child: _ViewModeButton(
                      icon: Icons.view_agenda_rounded,
                      tooltip: 'List view'.tr,
                      amount: t,
                      onTap: onList,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.icon,
    required this.tooltip,
    required this.amount,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final double amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox.expand(
          child: Icon(
            icon,
            size: 22,
            color: Color.lerp(AppColor.grey2, Colors.white, amount.clamp(0, 1)),
          ),
        ),
      ),
    );
  }
}

class HomeAdsPages extends StatefulWidget {
  const HomeAdsPages({
    super.key,
    required this.controller,
    required this.items,
    required this.showFooter,
  });

  final PageController controller;
  final List<ProductModel> items;
  final bool showFooter;

  @override
  State<HomeAdsPages> createState() => _HomeAdsPagesState();
}

class _HomeAdsPagesState extends State<HomeAdsPages> {
  final _heights = <int, double>{};
  final _viewport = ValueNotifier<double>(1);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncHeight);
  }

  @override
  void didUpdateWidget(HomeAdsPages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncHeight);
      widget.controller.addListener(_syncHeight);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncHeight);
    _viewport.dispose();
    super.dispose();
  }

  void _setHeight(int index, double height) {
    if (_heights[index] == height) return;
    _heights[index] = height;
    _syncHeight();
  }

  void _syncHeight() {
    final page = widget.controller.hasClients
        ? (widget.controller.page ?? widget.controller.initialPage.toDouble())
        : widget.controller.initialPage.toDouble();
    final grid = _heights[0] ?? 0;
    final list = _heights[1] ?? 0;
    final t = page.clamp(0.0, 1.0);
    final height = grid == 0
        ? list
        : list == 0
            ? grid
            : lerpDouble(grid, list, t)!;
    if (height > 0 && height != _viewport.value) {
      _viewport.value = height;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _viewport,
      builder: (context, height, child) {
        return SizedBox(height: height, width: double.infinity, child: child);
      },
      child: PageView(
        controller: widget.controller,
        physics: const NeverScrollableScrollPhysics(),
        allowImplicitScrolling: true,
        children: [
          _ExpandedPage(
            onHeight: (height) => _setHeight(0, height),
            child: _AdsGridPage(
              items: widget.items,
              showFooter: widget.showFooter,
            ),
          ),
          _ExpandedPage(
            onHeight: (height) => _setHeight(1, height),
            child: _AdsListPage(
              items: widget.items,
              showFooter: widget.showFooter,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdsGridPage extends StatelessWidget {
  const _AdsGridPage({required this.items, required this.showFooter});

  final List<ProductModel> items;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      itemCount: items.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) return const _AdsPageFooter();
        return ProductTile(product: items[index]);
      },
    );
  }
}

class _AdsListPage extends StatelessWidget {
  const _AdsListPage({required this.items, required this.showFooter});

  final List<ProductModel> items;
  final bool showFooter;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
      itemCount: items.length + (showFooter ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= items.length) return const _AdsPageFooter();
        return HomeAdListCard(product: items[index]);
      },
    );
  }
}

class _ExpandedPage extends SingleChildRenderObjectWidget {
  const _ExpandedPage({required this.onHeight, required super.child});

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderExpandedPage(onHeight: onHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderExpandedPage renderObject,
  ) {
    renderObject.onHeight = onHeight;
  }
}

class _RenderExpandedPage extends RenderProxyBox {
  _RenderExpandedPage({required this.onHeight});

  ValueChanged<double> onHeight;
  double? _reported;

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = Size(constraints.maxWidth, constraints.maxHeight);
      return;
    }
    child.layout(
      BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      parentUsesSize: true,
    );
    final viewport = constraints.maxHeight.isFinite ? constraints.maxHeight : child.size.height;
    size = Size(constraints.maxWidth, viewport);
    final height = child.size.height;
    if (height > 0 && height != _reported) {
      _reported = height;
      WidgetsBinding.instance.addPostFrameCallback((_) => onHeight(height));
    }
  }
}

class _AdsPageFooter extends StatelessWidget {
  const _AdsPageFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: LoadingWidget(size: 24),
    );
  }
}

class HomeAdListCard extends ConsumerWidget {
  const HomeAdListCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = getIt<LocaleService>().getLocale().locale.languageCode;
    final title = product.getProductName(langCode);
    final age = adAgeLabel(product.createdAt);
    final seller = product.sellerName?.trim() ?? '';
    final image = product.thumbImage;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Get.to(
            () => AdDetailsScreen(productId: product.id),
            preventDuplicates: false,
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xffEFEFEF)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 168,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          child: image != null && image.isNotEmpty
                              ? ImageOrSvg(image, fit: BoxFit.cover)
                              : const ColoredBox(color: Color(0xffE4E4E4)),
                        ),
                      ),
                      PositionedDirectional(
                        top: 10,
                        start: 10,
                        child: _ImageAction(
                          child: GestureDetector(
                            onTap: () {
                              SharePlus.instance.share(
                                ShareParams(text: title),
                              );
                            },
                            child: Icon(
                              Icons.share_outlined,
                              size: 18,
                              color: AppColor.black,
                            ),
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        top: 10,
                        end: 10,
                        child: _ImageAction(
                          child: FavoriteButton(
                            product: product,
                            ref: ref,
                            size: 36,
                            color: AppColor.danger,
                            activeColor: AppColor.danger,
                            isFavorited: ref.watch(
                              isFavoritedProduct(product.id),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppFont.font16W700Black,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Gap(8),
                          if (product.hasListedPrice)
                            PriceWidget(
                              price: _wholePrice(product.price!),
                              style: AppFont.font16W700Primary,
                              textColor: AppColor.primary,
                              currencySize: 16,
                            )
                          else
                            Flexible(
                              child: Text(
                                'Contact the publisher'.tr,
                                style: AppFont.font12W600Primary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const Gap(8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColor.grey2,
                          ),
                          const Gap(6),
                          Text(
                            age,
                            style: AppFont.font12w400Black.copyWith(
                              color: AppColor.grey2,
                            ),
                          ),
                          const Spacer(),
                          if (seller.isNotEmpty)
                            Flexible(
                              child: Text(
                                seller,
                                style: AppFont.font12w400Black.copyWith(
                                  color: AppColor.grey2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageAction extends StatelessWidget {
  const _ImageAction({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

String adAgeLabel(String createdAt) {
  final date = DateTime.tryParse(createdAt);
  if (date == null) return '';
  final diff = DateTime.now().difference(date.toLocal());
  if (diff.isNegative || diff.inMinutes < 1) return 'Just now'.tr;
  if (diff.inMinutes < 60) {
    return '%s mins ago'.trArgs(['${diff.inMinutes}']);
  }
  if (diff.inHours < 24) {
    return '%s hours ago'.trArgs(['${diff.inHours}']);
  }
  if (diff.inDays == 1) return '1 day ago'.tr;
  return '%s days ago'.trArgs(['${diff.inDays}']);
}

String _wholePrice(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2);
}
