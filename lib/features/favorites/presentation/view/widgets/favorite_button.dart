import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../../../config/app_color.dart';
import '../../../../../main.dart';
import '../../../../../ui/ui.dart';
import '../../../../favorites/domain/use_case/favorites_use_case.dart';
import '../../../../favorites/presentation/managers/favorites.dart';
import '../../../../products/data/models/product_model.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.product,
    required this.ref,
    required this.isFavorited,
    this.isOutlined = false,
    this.size, this.color = Colors.white,
  });

  final ProductModel product;
  final WidgetRef ref;
  final bool isFavorited;
  final bool isOutlined;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final res = await getIt<AddOrDeleteFavoritesUseCase>().call(
          product.id.toString(),
        );
        res.fold((l) {
          UIHelper.showGlobalSnackBar(
              text: "Something went wrong".tr, color: AppColor.danger2);
        }, (r) {
          UIHelper.showGlobalSnackBar(
              text: isFavorited
                  ? "Product Removed from favorites successfully".tr
                  : "Product Added to favorites successfully".tr,
              color: AppColor.primary);
        });
        ref.invalidate(favoritesProvider);
      },
      child: Icon(
        isFavorited ? Icons.favorite : Icons.favorite_border,
        size: size != null ? size! * .5 : 20,
        color: isFavorited ? AppColor.primary : color,
      ),
    );
  }
}