import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/config/app_font.dart';
import 'package:heraj/core/service/auth_service.dart';
import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/features/auth/presentation/view/login_page.dart';
import 'package:heraj/features/plans/presentation/view/plans_screen.dart';
import 'package:heraj/features/payments/presentation/view/payments_list_screen.dart';
import 'package:heraj/features/root/view/root_view.dart';
import 'package:heraj/features/root/controller/root_controller.dart';
import 'package:heraj/features/store/presentation/view/store_details_screen.dart';
import 'package:heraj/features/vendor/presentation/managers/vendor_provider.dart';
import 'package:heraj/ui/shared_widgets/image_or_svg.dart';
import 'package:heraj/ui/shared_widgets/shimmer_effect.dart';
import '../../../../core/enum/language.dart';
import '../../../../core/service/localization_service/localization_service.dart';
import '../../../../helper/riverpod.dart';
import '../../../settings/presentation/View/languages_screen.dart';
import '../../../settings/presentation/View/widgets/setting_item_widget.dart';
import '../../data/models/vendor_profile_model.dart';

class VendorProfileScreen extends ConsumerWidget {
  const VendorProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(fetchVendorProfileProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchVendorProfileProvider);
        },
        child: profileAsync.customWhen(
          ref: ref,
          refreshable: fetchVendorProfileProvider.future,
          data: (profile) => _buildContent(context, ref, profile, user),
          loading: () => _buildLoading(),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, VendorProfileModel profile, user) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: false,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(225),
                ),
                child: Icon(Icons.more_vert, color: AppColor.grey2),
              ),
              onPressed: () {},
            ),
            const Gap(8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColor.grey1,
                    backgroundImage:
                        profile.logo != null && profile.logo!.isNotEmpty
                            ? NetworkImage(profile.logo!)
                            : null,
                    child: profile.logo == null || profile.logo!.isEmpty
                        ? Icon(Icons.store, color: AppColor.primary, size: 40)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            background: Column(
              children: [
                SizedBox(
                  height: 170,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (profile.banner != null && profile.banner!.isNotEmpty)
                        ImageOrSvg(profile.banner!,
                            fit: BoxFit.cover, height: 170)
                      else
                        Container(
                          height: 170,
                          color: AppColor.primary.withAlpha(30),
                          child: Center(
                            child: Icon(Icons.store,
                                size: 64, color: AppColor.primary),
                          ),
                        ),
                    ],
                  ),
                ),
                Gap(50),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  user?.name ?? profile.storeName,
                  style: AppFont.font20W700Black,
                ),
                const Gap(8),
                Text(
                  '• ${profile.address} • ${profile.email}',
                  style: AppFont.font14W500Black.copyWith(
                    color: AppColor.grey2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(32),
                _buildBasicInfo(profile),
                const Gap(24),
                _buildAccountOptions(context, ref, profile),
                const Gap(24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: Colors.white,
          flexibleSpace: ShimmerEffect(
            enable: true,
            child: Container(color: Colors.white),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ShimmerEffect(
                    enable: true,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo(VendorProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic info'.tr,
          style: AppFont.font18W700Black,
        ),
        const Gap(16),
        _InfoRow(
          icon: Icons.email_outlined,
          text: profile.email,
        ),
        const Divider(height: 1),
        _InfoRow(
          icon: Icons.phone_outlined,
          text: profile.phone,
        ),
        const Divider(height: 1),
        _InfoRow(
          icon: Icons.business_outlined,
          text: profile.address,
        ),
      ],
    );
  }

  Widget _buildAccountOptions(BuildContext context, WidgetRef ref, VendorProfileModel profile) {
    final currentLocale = localeService.getLocale();
    final isArabic = currentLocale == Language.arabic;
    final isVendorFlow = ref.watch(isVendorFlowProvider);

    return Column(
      children: [
        SettingsItem(
          onTap: null,
          icon: Icons.person,
          title: 'User Mode'.tr,
          trailing: SizedBox(
            child: CupertinoSwitch(
              value: !isVendorFlow,
              onChanged: (value) {
                ref.read(isVendorFlowProvider.notifier).state = !value;
                dataManager.setVendorFlow(!value);
                ref.read(rootIndex.notifier).reset();
              },
              activeTrackColor: AppColor.primary,
            ),
          ),
          showArrow: false,
        ),
        const Divider(height: 1),
        SettingsItem(
          onTap: () {
            Get.to(() => StoreDetailsScreen(vendorId: profile.id));
          },
          icon: Icons.store_outlined,
          title: 'Store Info'.tr,
        ),
        const Divider(height: 1),

        SettingsItem(
          onTap: () {
            Get.to(() => PlansScreen());
          },
          icon: Icons.account_balance_wallet_outlined,
          title: 'Pricing Plan'.tr,
        ),
        const Divider(height: 1),
        SettingsItem(
          onTap: () => Get.to(() => const PaymentsListScreen()),
          icon: Icons.payment_outlined,
          title: 'My Payments'.tr,
        ),
        const Divider(height: 1),
        SettingsItem(
          onTap: () => Get.to(() => const LanguagesScreen()),
          icon: Icons.language,
          title: 'Language'.tr,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        const Divider(height: 1),
        SettingsItem(
          onTap: () {},
          icon: Icons.person_remove_outlined,
          title: 'Delete Account'.tr,
          color: AppColor.danger,
        ),
        const Divider(height: 1),
        SettingsItem(
          onTap: () {
            dataManager.removeLoggedUser();
            Get.offAll(() => const LoginPage());
          },
          icon: Icons.logout_outlined,
          title: 'Logout'.tr,
        ),
        const Gap(50)
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColor.grey2),
          const Gap(16),
          Expanded(
            child: Text(
              text,
              style: AppFont.font14W500Black.copyWith(
                color: AppColor.grey2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
