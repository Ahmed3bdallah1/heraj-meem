import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/features/address/presentation/view/address_screen.dart';
import 'package:heraj/features/auth/presentation/view/register_page.dart';
import 'package:heraj/helper/extensions/adaptive_view.dart';
import 'package:heraj/helper/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/app_font.dart';
import '../../../../core/service/local_data_manager.dart';
import '../../../../core/service/localization_service/localization_service.dart';
import '../../../../core/service/auth_service.dart';
import '../../../../core/service/fcm_token_service.dart';
import '../../../../core/enum/language.dart';
import '../../../../main.dart';
import '../../../../models/user_model.dart';
import '../../../../ui/shared_widgets/custom_image_circle.dart';
import '../../../auth/domain/use_cases/login_user_use_case.dart';
import '../../../auth/presentation/view/login_page.dart';
import '../../../favorites/presentation/view/favorites_list_screen.dart';
import '../../../orders/presentation/view/orders_screen.dart';
import '../../../root/view/root_view.dart';
import '../../../root/controller/root_controller.dart';
import '../../../plans/presentation/view/plans_screen.dart';
import '../../../profile/presentation/view/update_profile_view.dart';
import '../../../payments/presentation/view/payments_list_screen.dart';
import 'help_support_screen.dart';
import 'languages_screen.dart';
import 'privacy_policy_screen.dart';
import 'widgets/delete_account_bottom_sheet.dart';
import 'widgets/setting_item_widget.dart';
import '../../../auth/presentation/view/widgets/logout_confirmation_bottom_sheet.dart';

final _tokenProvider = Provider<bool>((ref) {
  return dataManager.getToken() != null;
});

final _notificationsEnabledProvider = StateProvider<bool>((ref) {
  return dataManager.notificationEnabled();
});

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    responsiveInit(context);
    final hasToken = ref.watch(_tokenProvider);
    final user = ref.watch(userProvider) ?? dataManager.getUser();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: CustomScrollView(
          slivers: [
            _WelcomeHeader(user: user, hasToken: hasToken),
            const SliverGap(16),
            const _MyProfileHeading(),
            _SettingsAdaptiveView(),
            SliverGap(MediaQuery.of(context).padding.bottom + 40)
          ],
        ),
      ),
    );
  }
}

class _SettingsAdaptiveView extends StatelessWidget {
  const _SettingsAdaptiveView();

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return SliverList(
        delegate: SliverChildListDelegate([
          const Gap(10),
          _MyProfileSectionContent(),
          const Gap(10),
          _SettingsSectionContent(),
          const Gap(10),
          const _DeleteAccountSectionContent(),
        ]),
      );
    } else {
      return SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: const [
                  _MyProfileSectionContent(),
                  Gap(10),
                  _DeleteAccountSectionContent()
                ],
              ),
            ),
            const Gap(20),
            const Expanded(child: _SettingsSectionContent()),
          ],
        ),
      );
    }
  }
}

// Helper widgets to extract content from sliver widgets
class _MyProfileSectionContent extends StatelessWidget {
  const _MyProfileSectionContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: AppColor.grey1.withAlpha(100),
                blurRadius: 10,
                spreadRadius: 1)
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SettingsItem(
            onTap: () => Get.to(() => const UpdateProfileView()),
            icon: Icons.person_outline,
            title: 'Personal Information'.tr,
          ),
          const _SettingsDivider(),
          SettingsItem(
            onTap: () => Get.to(() => const AddressScreen()),
            icon: Icons.location_city,
            title: 'Addresses'.tr,
          ),
          const _SettingsDivider(),
          SettingsItem(
            onTap: () => Get.to(() => const FavoritesListScreen()),
            icon: CupertinoIcons.heart,
            title: 'Favorites'.tr,
          ),
          const _SettingsDivider(),
          SettingsItem(
            onTap: () => Get.to(() => const OrdersScreen()),
            icon: Icons.shopping_cart_outlined,
            title: 'My Orders'.tr,
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionContent extends ConsumerWidget {
  const _SettingsSectionContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(_notificationsEnabledProvider);
    final currentLocale = localeService.getLocale();
    final isArabic = currentLocale == Language.arabic;

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: AppColor.grey1.withAlpha(100),
                blurRadius: 10,
                spreadRadius: 1)
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(
            builder: (context) {
              final user = ref.watch(userProvider) ?? dataManager.getUser();
              final hasVendorRole = (user?.role ?? "user") == "vendor";
              final isVendorFlow = ref.watch(isVendorFlowProvider);

              if (hasVendorRole) {
                return Column(
                  children: [
                    SettingsItem(
                      onTap: null,
                      icon: Icons.store,
                      title: 'Vendor Mode'.tr,
                      trailing: SizedBox(
                        child: CupertinoSwitch(
                          value: isVendorFlow,
                          onChanged: (value) {
                            ref.read(isVendorFlowProvider.notifier).state =
                                value;
                            dataManager.setVendorFlow(value);
                            ref.read(rootIndex.notifier).reset();
                          },
                          activeTrackColor: AppColor.primary,
                        ),
                      ),
                      showArrow: false,
                    ),
                    const _SettingsDivider(),
                  ],
                );
              } else {
                return Column(
                  children: [
                    SettingsItem(
                      onTap: () {
                        Get.to(() => const RegisterPage());
                      },
                      icon: Icons.store,
                      title: 'Register As New Vendor'.tr,
                      showArrow: true,
                    ),
                    const _SettingsDivider(),
                  ],
                );
              }
            },
          ),
          SettingsItem(
            onTap: null,
            icon: Icons.notifications_outlined,
            title: 'Notifications'.tr,
            trailing: SizedBox(
              child: CupertinoSwitch(
                value: notificationsEnabled,
                onChanged: (value) {
                  ref.read(_notificationsEnabledProvider.notifier).state =
                      value;
                  dataManager.setNotificationEnabled(value);
                },
                activeTrackColor: AppColor.primary,
              ),
            ),
            showArrow: false,
          ),
          const _SettingsDivider(),
          SettingsItem(
            onTap: () => Get.to(() => const LanguagesScreen()),
            icon: Icons.language,
            title: 'Language'.tr,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isArabic ? Colors.transparent : AppColor.primary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isArabic ? AppColor.grey1 : AppColor.primary,
                    ),
                  ),
                  child: Text(
                    'En',
                    style: AppFont.font12w500Grey2.copyWith(
                      color: isArabic ? AppColor.grey2 : Colors.white,
                    ),
                  ),
                ),
                const Gap(6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isArabic ? AppColor.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isArabic ? AppColor.primary : AppColor.grey1,
                    ),
                  ),
                  child: Text(
                    'ع',
                    style: AppFont.font12w500Grey2.copyWith(
                      color: isArabic ? Colors.white : AppColor.grey2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _SettingsDivider(),
          SettingsItem(
            onTap: () => Get.to(() => const PlansScreen()),
            icon: Icons.account_balance_wallet_outlined,
            title: 'Pricing Plan'.tr,
          ),
          const _SettingsDivider(),
          SettingsItem(
            onTap: () => Get.to(() => const PaymentsListScreen()),
            icon: Icons.payment_outlined,
            title: 'My Payments'.tr,
          ),
          const _SettingsDivider(),
          SettingsItem(
            onTap: () => Get.to(() => const HelpSupportScreen()),
            icon: Icons.help_outline,
            title: 'Help & Support'.tr,
          ),
          const _SettingsDivider(),
          SettingsItem(
            onTap: () => Get.to(() => const PrivacyPolicyScreen()),
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy'.tr,
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountSectionContent extends StatelessWidget {
  const _DeleteAccountSectionContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: AppColor.grey1.withAlpha(100),
                blurRadius: 10,
                spreadRadius: 1)
          ]),
      child: Column(
        children: [
          SettingsItem(
            onTap: () => _showLogoutConfirmation(context),
            icon: Icons.logout,
            color: AppColor.danger,
            title: 'Log out'.tr,
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    LogoutConfirmationBottomSheet.show(
      context,
      onConfirm: () => _handleLogout(context),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }

    if (Get.isDialogOpen == true) {
      Get.back();
    }
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    await Future.delayed(const Duration(milliseconds: 100));

    if (dataManager.getToken() != null) {
      try {
        await getIt<FCMTokenService>().removeFCMToken();
      } catch (e) {
        print('Error removing FCM token: $e');
      }

      await getIt<LogOutUserUseCase>().call();
      await localeService.dataManager.removeLoggedUser();
    }

    Get.offAll(() => const LoginPage());
  }
}

class _WelcomeHeader extends StatelessWidget {
  final UserModel? user;
  final bool hasToken;

  const _WelcomeHeader({required this.user, required this.hasToken});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SliverToBoxAdapter(
      child: Column(
        children: [
          SizedBox(height: topPadding),
          if (hasToken && user != null)
            Row(
              children: [
                CustomImageCircle(
                  image: user?.image ?? "",
                  radius: 20,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome'.tr,
                        style: AppFont.font12w500Grey2,
                      ),
                      const Gap(4),
                      Text(
                        user?.name ?? "",
                        style: AppFont.font18W700Black,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MyProfileHeading extends StatelessWidget {
  const _MyProfileHeading();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          'My Profile'.tr,
          style: AppFont.font18W700Black,
        ),
      ),
    );
  }
}

class _MyProfileSection extends StatelessWidget {
  const _MyProfileSection();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: AppColor.grey1.withAlpha(100),
                  blurRadius: 10,
                  spreadRadius: 1)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SettingsItem(
              onTap: () => Get.to(() => const UpdateProfileView()),
              icon: Icons.person_outline,
              title: 'Personal Information'.tr,
            ),
            const _SettingsDivider(),
            SettingsItem(
              onTap: () => Get.to(() => const AddressScreen()),
              icon: Icons.location_city,
              title: 'Addresses'.tr,
            ),
            const _SettingsDivider(),
            SettingsItem(
              onTap: () => Get.to(() => const FavoritesListScreen()),
              icon: CupertinoIcons.heart,
              title: 'Favorites'.tr,
            ),
            const _SettingsDivider(),
            SettingsItem(
              onTap: () => Get.to(() => const OrdersScreen()),
              icon: Icons.shopping_cart_outlined,
              title: 'My Orders'.tr,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends ConsumerWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsEnabled = ref.watch(_notificationsEnabledProvider);
    final currentLocale = localeService.getLocale();
    final isArabic = currentLocale == Language.arabic;

    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: AppColor.grey1.withAlpha(100),
                  blurRadius: 10,
                  spreadRadius: 1)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Builder(
              builder: (context) {
                final user = ref.watch(userProvider) ?? dataManager.getUser();
                final hasVendorRole = (user?.role ?? "user") == "vendor";
                final isVendorFlow = ref.watch(isVendorFlowProvider);

                if (hasVendorRole) {
                  return Column(
                    children: [
                      SettingsItem(
                        onTap: null,
                        icon: Icons.store,
                        title: 'Vendor Mode'.tr,
                        trailing: SizedBox(
                          child: CupertinoSwitch(
                            value: isVendorFlow,
                            onChanged: (value) {
                              ref.read(isVendorFlowProvider.notifier).state =
                                  value;
                              dataManager.setVendorFlow(value);
                              ref.read(rootIndex.notifier).reset();
                            },
                            activeTrackColor: AppColor.primary,
                          ),
                        ),
                        showArrow: false,
                      ),
                      const _SettingsDivider(),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      SettingsItem(
                        onTap: () {
                          Get.to(() => const RegisterPage());
                        },
                        icon: Icons.store,
                        title: 'Register As New Vendor'.tr,
                        showArrow: true,
                      ),
                      const _SettingsDivider(),
                    ],
                  );
                }
              },
            ),
            SettingsItem(
              onTap: null,
              icon: Icons.notifications_outlined,
              title: 'Notifications'.tr,
              trailing: SizedBox(
                child: CupertinoSwitch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    ref.read(_notificationsEnabledProvider.notifier).state =
                        value;
                    dataManager.setNotificationEnabled(value);
                  },
                  activeTrackColor: AppColor.primary,
                ),
              ),
              showArrow: false,
            ),
            const _SettingsDivider(),
            SettingsItem(
              onTap: () => Get.to(() => const LanguagesScreen()),
              icon: Icons.language,
              title: 'Language'.tr,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isArabic ? Colors.transparent : AppColor.primary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isArabic ? AppColor.grey1 : AppColor.primary,
                      ),
                    ),
                    child: Text(
                      'En',
                      style: AppFont.font12w500Grey2.copyWith(
                        color: isArabic ? AppColor.grey2 : Colors.white,
                      ),
                    ),
                  ),
                  const Gap(6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isArabic ? AppColor.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isArabic ? AppColor.primary : AppColor.grey1,
                      ),
                    ),
                    child: Text(
                      'ع',
                      style: AppFont.font12w500Grey2.copyWith(
                        color: isArabic ? Colors.white : AppColor.grey2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const _SettingsDivider(),
            SettingsItem(
              onTap: () => Get.to(() => const PlansScreen()),
              icon: Icons.account_balance_wallet_outlined,
              title: 'Pricing Plan'.tr,
            ),
            const _SettingsDivider(),
            SettingsItem(
              onTap: () => Get.to(() => const PaymentsListScreen()),
              icon: Icons.payment_outlined,
              title: 'My Payments'.tr,
            ),
            const _SettingsDivider(),
            SettingsItem(
              onTap: () => Get.to(() => const HelpSupportScreen()),
              icon: Icons.help_outline,
              title: 'Help & Support'.tr,
            ),
            const _SettingsDivider(),
            SettingsItem(
              onTap: () => Get.to(() => const PrivacyPolicyScreen()),
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy'.tr,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteAccountSection extends StatelessWidget {
  const _DeleteAccountSection();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: AppColor.grey1.withAlpha(100),
                    blurRadius: 10,
                    spreadRadius: 1)
              ]),
          child: Column(
            children: [
              // SettingsItem(
              //   onTap: () => _showDeleteAccountDialog(context),
              //   icon: Icons.person_off,
              //   title: "Delete Account".tr,
              //   color: AppColor.danger,
              // ),
              // const _SettingsDivider(),
              SettingsItem(
                onTap: () => _showLogoutConfirmation(context),
                icon: Icons.logout,
                color: AppColor.danger,
                title: 'Log out'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    GeneralBottomSheet.show(
      context,
      'Deleting Account'.tr,
      description: "Are you sure about deleting your account".tr,
      isError: true,
      onPressed: () async {},
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    LogoutConfirmationBottomSheet.show(
      context,
      onConfirm: () => _handleLogout(context),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }

    if (Get.isDialogOpen == true) {
      Get.back();
    }
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    await Future.delayed(const Duration(milliseconds: 100));

    if (dataManager.getToken() != null) {
      try {
        await getIt<FCMTokenService>().removeFCMToken();
      } catch (e) {
        print('Error removing FCM token: $e');
      }

      await getIt<LogOutUserUseCase>().call();
      await localeService.dataManager.removeLoggedUser();
    }

    Get.offAll(() => const LoginPage());
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const DottedDivider(padding: 8);
  }
}

class DottedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double spacing;
  final double padding;
  final double dotSize;

  const DottedDivider({
    super.key,
    this.height = 1,
    this.color = const Color(0xffd0d9e5),
    this.spacing = 4,
    this.padding = 0,
    this.dotSize = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dotSize + spacing)).floor();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return Container(
                width: dotSize,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(dotSize / 2),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
