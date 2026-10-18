import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/features/store/presentation/view/widgets/all_top_stores/verified_badge.dart';
import '../../../../../../config/app_color.dart';
import '../../../../../../ui/shared_widgets/image_or_svg.dart';
import '../../../../data/models/store_model.dart';
import '../../store_details_screen.dart';
import 'store_card_content.dart';

class StoreCard extends StatelessWidget {
  final StoreModel store;

  const StoreCard({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => StoreDetailsScreen(vendorId: store.id));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withAlpha(25),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: store.banner != null && store.banner!.isNotEmpty
                          ? ImageOrSvg(
                              store.banner!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : const _PlaceholderBanner(),
                    ),
                  ),
                ),
                PositionedDirectional(
                  bottom: 0,
                  start: 10,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: store.logo != null && store.logo!.isNotEmpty
                          ? ImageOrSvg(
                              store.logo!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : const _PlaceholderLogo(),
                    ),
                  ),
                ),
                if (store.hasPremiumBadge) const VerifiedBadge(),
              ],
            ),
            StoreCardContent(store: store),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderBanner extends StatelessWidget {
  const _PlaceholderBanner();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primary.withAlpha(75),
            AppColor.primary.withAlpha(25),
          ],
        ),
      ),
      child: Icon(
        Icons.store,
        color: AppColor.primary.withAlpha(125),
        size: 50,
      ),
    );
  }
}

class _PlaceholderLogo extends StatelessWidget {
  const _PlaceholderLogo();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primary,
            AppColor.primary.withAlpha(175),
          ],
        ),
      ),
      child: const Icon(
        Icons.store,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
