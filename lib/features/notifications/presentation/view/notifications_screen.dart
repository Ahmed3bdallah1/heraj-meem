import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:flutter/foundation.dart';
import 'package:heraj/features/notifications/presentation/view/widgets/notification_action_chip.dart';
import 'package:heraj/features/notifications/presentation/view/widgets/notifications_container.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../main.dart';
import '../../../../../ui/shared_widgets/hide_nav_bar_widget.dart';
import '../../../../../ui/shared_widgets/not_found_widget.dart';
import '../../../../config/app_font.dart';
import '../../../products/presentation/view/widgets/sell_all_products/animated_background.dart';
import '../../domain/use_case/mark_all_as_read_use_case.dart';
import '../managers/fetch_notificatons_provider.dart';
import '../managers/notifications_filter.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with SingleTickerProviderStateMixin {
  late final AutoDisposeStateProvider<bool> hideNavBarProvider2;
  bool _hasMarkedAllAsRead = false;
  late AnimationController _backgroundAnimationController;

  @override
  void initState() {
    super.initState();
    hideNavBarProvider2 = StateProvider.autoDispose<bool>((ref) {
      return false;
    });
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasMarkedAllAsRead) {
      _markAllAsRead();
    }
  }

  Future<void> _markAllAsRead() async {
    if (_hasMarkedAllAsRead) return;
    try {
      final result = await getIt<MarkAllAsReadUseCase>().call();
      result.fold(
        (failure) {},
        (success) {
          _hasMarkedAllAsRead = true;
          if (mounted) {
            ref.invalidate(fetchNotificationsProvider);
            ref.invalidate(unreadNotificationCountProvider);
          }
        },
      );
    } catch (e) {
      if(kDebugMode){
        print("Error marking all notifications as read: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            animation: _backgroundAnimationController,
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 100,
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColor.black,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
                  title: Text(
                    "Notifications".tr,
                    style: AppFont.font20W700Black,
                  ),
                  centerTitle: false,
                ),
              ),
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    AnimatedSizeAndFade.showHide(
                        show: !ref.watch(hideNavBarProvider2),
                        child: Consumer(builder: (context, ref, child) {
                          const data = NotificationFilterType.values;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Row(
                                  children: data
                                      .map(
                                        (e) =>
                                            NotificationsCustomActionChip(value: e),
                                      )
                                      .toList()),
                            ),
                          );
                        })),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: HideNavBarWidget(
                  customProvider: hideNavBarProvider2,
                  child: Consumer(builder: (context, ref, _) {
                    final notificationsList = ref.watch(fetchNotificationsProvider);
                    return notificationsList.customWhen(
                        ref: ref,
                        refreshable: fetchNotificationsProvider.future,
                        data: (notifications) {
                          if (notifications.isEmpty) {
                            return NotFoundWidget(
                                haveIcon: true,
                                title: "No Notifications right now.!".tr);
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return NotificationContainer(
                                      notificationEntity: notifications[index]);
                                },
                                separatorBuilder: (context, index) {
                                  return const Gap(10);
                                },
                                itemCount: notifications.length),
                          );
                        },
                        loading: () {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey[900]!,
                                  highlightColor: Colors.green[100]!,
                                  child: Container(
                                    height: 180,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withAlpha(38),
                                      borderRadius: BorderRadius.circular(35),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        });
                  }),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
