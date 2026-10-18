import 'package:get/get.dart';
import 'package:heraj/config/app_color.dart';
import 'package:heraj/features/products/presentation/view/product_details_screen.dart';
import 'package:heraj/features/categories/presentation/view/category_screen.dart';
import 'package:heraj/features/categories/data/models/main_category_model.dart';
import 'package:heraj/helper/responsive.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../../store/presentation/view/store_category_screen.dart';
import '../../../domain/entities/ad_entity.dart';

class SliderItem extends StatelessWidget {
  const SliderItem(
    this.item, {
    super.key,
  });

  final AdEntity item;

  void _handleTap(BuildContext context) {
    if (item.linkId == null || item.linkId!.isEmpty) {
      return;
    }

    switch (item.linkType.toLowerCase()) {
      case 'product':
        Get.to(() => ProductDetailsScreen(productId: item.linkId!));
        break;
      case 'category':
        final category = CategoryModel(
          id: item.linkId!,
          name: item.title,
          nameTr: item.title,
          nameAr: item.title,
          slug: '',
          level: 1,
          order: 0,
          isActive: true,
          createdAt: '',
          updatedAt: '',
          v: 0,
        );
        Get.to(() => CategoryScreen(category: category));
        break;
      case 'admincategory':
        final category = CategoryModel(
          id: item.linkId!,
          name: item.title,
          nameTr: item.title,
          nameAr: item.title,
          slug: '',
          level: 1,
          order: item.order,
          isActive: item.isActive,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
          v: item.v,
        );
        Get.to(() => StoreCategoryScreen(category));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: ImageOrSvg(
            item.image,
            fit: BoxFit.fill,
            isLocal: false,
          ),
        ),
      ),
    );
  }
}

class SliderProductItem extends StatelessWidget {
  const SliderProductItem(
    this.path, {
    super.key,
  });

  final String path;

  // final String id;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => Get.to(()=>ProductDetailsScreen(productId: id)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: ImageOrSvg(
            path,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

class SliderShimmerItem extends StatelessWidget {
  final double? size;

  const SliderShimmerItem({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Shimmer.fromColors(
        baseColor: AppColor.black.withOpacity(.09),
        highlightColor: Colors.grey.withOpacity(.6),
        child: Container(
          height: size ?? 160,
          width: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
