import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:heraj/features/home/presentation/view/home_screen.dart';
import 'package:heraj/features/products/presentation/view/add_product_screen.dart';
import 'package:heraj/features/settings/presentation/View/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/features/vendor/presentation/view/my_ads_screen.dart';
import 'package:heraj/features/vendor/presentation/view/vendor_dashboard_screen.dart';
import 'package:heraj/features/vendor/presentation/view/vendor_profile_screen.dart';
import 'package:heraj/features/chats/presentation/view/chats_list_screen.dart';
import '../../../../config/app_font.dart';
import '../../../../core/service/auth_service.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helper/responsive.dart';
import '../../../../packages/flutter_close_app.dart';
import '../../../core/service/local_data_manager.dart';
import '../../store/presentation/view/open_store_page.dart';
import '../controller/root_controller.dart';

final hideNavBarProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

final rootViewProvider = StateProvider.autoDispose<int>((ref) {
  return 1;
});

final isVendorFlowProvider = StateProvider.autoDispose<bool>((ref) {
  final user = ref.watch(userProvider);
  final hasVendorRole = (user?.role ?? "user") == "vendor";

  if (hasVendorRole) {
    if (dataManager.hasVendorFlowPreference()) {
      return dataManager.getVendorFlow();
    } else {
      return true;
    }
  }

  return false;
});

class RootView extends ConsumerStatefulWidget {
  const RootView({super.key});

  @override
  ConsumerState<RootView> createState() => _RootViewState();
}

class _RootViewState extends ConsumerState<RootView> {
  // this is const instances to avoid rebuilding the screens every time
  // reduced the loading time when switching between tabs by 260%
  final Widget _homeScreen = const HomeScreen();
  final Widget _vendorDashboardScreen = const VendorDashboardScreen();
  final Widget _openStoreView = const OpenStoreView();
  final Widget _myAdsScreen = const MyAdsScreen();
  final Widget _addProductScreen = const AddProductScreen();
  final Widget _chatsListScreen = const ChatsListScreen();
  final Widget _settingsView = const SettingsView();
  final Widget _vendorProfileScreen = const VendorProfileScreen();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.watch(userProvider);
      if (user != null && mounted) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final selectedIndex = ref.watch(rootIndex);
    final controller = ref.read(rootIndex.notifier);
    final isVendorFlow = ref.watch(isVendorFlowProvider);

    return FlutterCloseAppPage(
      condition: selectedIndex == 0,
      onCloseFailed: () {
        if (selectedIndex != 0) {
          final controller = ref.read(rootIndex.notifier);
          controller.reset();
        } else {
          Fluttertoast.showToast(
            msg: 'Press again to exit'.tr,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: selectedIndex,
              children: _buildScreens(isVendorFlow),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom,
              left: 10,
              right: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColor.white.withAlpha(200),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withAlpha(50),
                          blurRadius: 20,
                          spreadRadius: 3,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: buildNavBar(selectedIndex, controller, isVendorFlow),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 25,
              left: MediaQuery.of(context).size.width / 2 - 35,
              child: GestureDetector(
                onTap: () => Get.to(() => const AddProductScreen()),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primary.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.add,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScreens(bool isVendor) {
    return [
      isVendor ? _vendorDashboardScreen : _homeScreen,
      isVendor ? _myAdsScreen : _openStoreView,
      _addProductScreen,
      _chatsListScreen,
      isVendor ? _vendorProfileScreen : _settingsView,
    ];
  }

  Widget buildNavBar(int selectedIndex, dynamic controller, bool isVendor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          icon: const Icon(Icons.home_filled, size: 28),
          label: "Home".tr,
          index: 0,
          isSelected: selectedIndex == 0,
          onTap: () => controller.setSelectedIndex(0),
        ),
        _buildNavItem(
          icon: const Icon(Icons.store, size: 28),
          label: "Store".tr,
          index: 1,
          isSelected: selectedIndex == 1,
          onTap: () => controller.setSelectedIndex(1),
        ),
        // Empty space for the center FAB
        const Expanded(child: SizedBox()),
        _buildNavItem(
          icon: Icon(
            selectedIndex == 3
                ? CupertinoIcons.chat_bubble_2_fill
                : CupertinoIcons.chat_bubble_2,
            size: 28,
          ),
          label: "Chats".tr,
          index: 3,
          isSelected: selectedIndex == 3,
          onTap: () => controller.setSelectedIndex(3),
        ),
        _buildNavItem(
          icon: SvgPicture.asset(
            Assets.socialMedia.profileCircle,
            height: 24,
            colorFilter: ColorFilter.mode(
              selectedIndex == 4 ? AppColor.primary : AppColor.grey2,
              BlendMode.srcIn,
            ),
          ),
          label: "More".tr,
          index: 4,
          isSelected: selectedIndex == 4,
          onTap: () => controller.setSelectedIndex(4),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required Widget icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconTheme(
                data: IconThemeData(
                  color: isSelected ? AppColor.primary : AppColor.grey2,
                  size: 28,
                ),
                child: icon,
              ),
              const Gap(4),
              Text(
                label,
                style: AppFont.font13W400Black.copyWith(
                  color: isSelected ? AppColor.primary : AppColor.grey2,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
