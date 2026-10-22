import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/favorites/presentation/managers/favorites.dart';
import 'package:heraj_meem/features/favorites/presentation/view/favorites_list_screen.dart';
import 'package:heraj_meem/features/notifications/presentation/managers/fetch_notificatons_provider.dart';
import 'package:heraj_meem/features/notifications/presentation/view/notifications_screen.dart';
import 'location_bottom_sheet.dart';
import '../../../../../config/app_font.dart';
import '../../../../../ui/shared_widgets/loading_widget.dart';
import '../../../../search/presentation/view/baho_search_screen.dart';
import '../../../../search/presentation/view/search_screen.dart';

class HomeHeaderWidget extends ConsumerWidget {
  final bool isHome;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomeHeaderWidget({
    super.key,
    this.isHome = false,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final place = ref.watch(bahoPlaceProvider);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await showLocationBottomSheet(context: context);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColor.primary.withAlpha(18),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: AppColor.primary,
                                size: 22,
                              ),
                            ),
                            const Gap(6),
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      place?.cityName ?? 'All regions'.tr,
                                      style: AppFont.font14W600Black,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Gap(4),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColor.black,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isHome) ...[
                      if (!(ref.watch(favoritesProvider).valueOrNull?.isEmpty ??
                          true)) ...[
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.heart,
                                color: AppColor.black,
                                size: 20,
                              ),
                              onPressed: () {
                                Get.to(() => const FavoritesListScreen());
                              },
                            ),
                            PositionedDirectional(
                                end: 8,
                                top: 8,
                                child: CircleAvatar(
                                  radius: 6,
                                  backgroundColor: AppColor.danger,
                                )),
                          ],
                        ),
                      ] else ...[
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.heart,
                            color: AppColor.black,
                            size: 20,
                          ),
                          onPressed: () {
                            Get.to(() => const FavoritesListScreen());
                          },
                        ),
                      ],
                    ],
                    if (!isHome)
                      IconButton(
                        icon: Icon(
                          Icons.category_outlined,
                          color: AppColor.black,
                          size: 20,
                        ),
                        onPressed: () {
                          if (scaffoldKey?.currentState != null) {
                            scaffoldKey!.currentState!.openEndDrawer();
                          } else {
                            Scaffold.of(context).openEndDrawer();
                          }
                        },
                      ),
                    ref.watch(unreadNotificationCountProvider).when(
                          data: (unreadCount) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    CupertinoIcons.bell,
                                    color: AppColor.black,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Get.to(() => const NotificationsScreen());
                                  },
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColor.danger,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColor.white,
                                          width: 2,
                                        ),
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Center(
                                        child: Text(
                                          unreadCount > 99
                                              ? '99+'
                                              : '$unreadCount',
                                          style:
                                              AppFont.font10w400Black.copyWith(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                          loading: () => IconButton(
                            icon: Icon(
                              CupertinoIcons.bell,
                              color: AppColor.black,
                              size: 20,
                            ),
                            onPressed: () {
                              Get.to(() => const NotificationsScreen());
                            },
                          ),
                          error: (_, __) => IconButton(
                            icon: Icon(
                              CupertinoIcons.bell,
                              color: AppColor.black,
                              size: 20,
                            ),
                            onPressed: () {
                              Get.to(() => const NotificationsScreen());
                            },
                          ),
                        ),
                  ],
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: TypeAheadField<String>(
                        builder: (context, controller, focusNode) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xffF3F4F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) {
                                final query = value.trim();
                                if (query.isEmpty) return;
                                Get.to(() => BahoSearchScreen(query: query));
                              },
                              decoration: InputDecoration(
                                hintText: 'Search in Baho...'.tr,
                                hintStyle: AppFont.font14W500Grey2,
                                prefixIcon: Icon(
                                  CupertinoIcons.search,
                                  color: AppColor.grey2,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColor.grey1.withAlpha(100)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColor.grey1.withAlpha(100)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: AppColor.primary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                filled: false,
                                fillColor: Colors.white,
                              ),
                              style: AppFont.font14W500Grey2,
                            ),
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          try {
                            return await fetchSearchSuggestions(pattern);
                          } catch (_) {
                            return <String>[];
                          }
                        },
                        itemBuilder: (context, String suggestion) {
                          return ListTile(
                            leading: Icon(
                              CupertinoIcons.search,
                              color: AppColor.grey2,
                              size: 18,
                            ),
                            minTileHeight: 48,
                            title: Text(
                              suggestion,
                              style: AppFont.font14W600Black,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        onSelected: (String suggestion) {
                          Get.to(() => BahoSearchScreen(query: suggestion));
                        },
                        emptyBuilder: (context) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No products found'.tr,
                            style: AppFont.font14W600Primary,
                          ),
                        ),
                        loadingBuilder: (context) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: const LoadingWidget(),
                        ),
                        errorBuilder: (context, error) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Error loading suggestions'.tr,
                            style: AppFont.font14W500Grey2,
                          ),
                        ),
                      ),
                    ),
                    if (!isHome) ...[
                      const Gap(8),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            Get.to(() => const SearchAllProductsScreen());
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
