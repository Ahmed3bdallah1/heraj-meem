import 'package:heraj_meem/features/offline/no_wifi.dart';
import 'package:heraj_meem/main.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
// import 'package:safe_device/safe_device.dart';
import '../../../../config/app_font.dart';
import '../../../../core/service/local_data_manager.dart';
import '../../../../core/service/remote_config_service.dart';
import '../../../../helper/responsive.dart';
import '../../../../ui/shared_widgets/error_widget.dart';
import '../../../../ui/shared_widgets/logo_widget.dart';
import '../../auth/presentation/view/login_page.dart';
import '../../onboarding/view/get_started_screen.dart';
import '../../onboarding/view/onboard_screen.dart';
import '../../root/view/root_view.dart';

import '../controllers/splash_controller.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((duration) async {
      Future.delayed(const Duration(seconds: 1));
      if (!await isRealDevice()) {
        Get.offAll(() => const ViolationScreen());
      }
    });
  }

  Future<bool> isRealDevice() async {
    await Future.delayed(const Duration(seconds: 1));
    // final isRealDevice = await SafeDevice.isRealDevice;
    // final isSafeDevice = await SafeDevice.isSafeDevice;
    //
    // return kDebugMode ? true : (isRealDevice && isSafeDevice);
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final provider = ref.watch(splashProvider);
    ref.listen(splashProvider, (previous, next) {
      if (previous?.hasValue == false && next.hasValue) {
        final hasPendingNotification = dataManager.getValue('pending_notification') != null;
        if (hasPendingNotification) {
          if (kDebugMode) {
            print('🔔 Pending notification detected, skipping splash navigation');
          }
          return;
        }

        final route = next.value!;
        if (route == SplashNavigate.forceUpdate) {
          // UI is handled in data: builder
          return;
        }

        final showOptional = ref.read(showOptionalUpdateDialogProvider);
        if (showOptional) {
          _showOptionalUpdateDialog(context, ref, route);
          return;
        }

        _navigateTo(route);
      }
    });
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final isUpdateAvailable = ref.watch(isUpdateAvailableProvider);
          if (isUpdateAvailable) {
            return Text(
              "${"Loading some updates".tr} ...",
              style: AppFont.font16W600Gray2,
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      body: provider.customWhen(
          refreshable: splashProvider.future,
          ref: ref,
          data: (data) {
            if (data == SplashNavigate.forceUpdate) {
              return _UpdateRequiredBody(
                storeLink: getIt<RemoteConfigService>().storeLink,
              );
            }
            return Center(
              child: ScaleTransition(
                scale: _animation,
                child: const LogoWidget(),
              ),
            );
          },
          error: (o, b) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LogoWidget(),
                      CustomErrorWidget(
                        object: "Oops!\nServer is under maintenance".tr,
                        stackTrace: b,
                        onRetry: () => ref.refresh(splashProvider.future),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => Center(
                child: ScaleTransition(
                  scale: _animation,
                  child: const LogoWidget(),
                ),
              )),
    );
  }

  void _navigateTo(SplashNavigate route) {
    switch (route) {
      case SplashNavigate.home:
        Get.offAll(() => const RootView());
        break;
      case SplashNavigate.getStarted:
        Get.offAll(() => const GetStartedScreen());
        break;
      case SplashNavigate.boarding:
        Get.offAll(() => const OnboardScreen());
        break;
      case SplashNavigate.login:
        Get.offAll(() => const LoginPage());
        break;
      case SplashNavigate.forceUpdate:
        break;
    }
  }

  void _showOptionalUpdateDialog(
    BuildContext context,
    WidgetRef ref,
    SplashNavigate route,
  ) {
    final storeLink = getIt<RemoteConfigService>().storeLink;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Update available'.tr),
        content: Text('Update available message'.tr),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(showOptionalUpdateDialogProvider.notifier).state = false;
              _navigateTo(route);
            },
            child: Text('Later'.tr),
          ),
          FilledButton(
            onPressed: () async {
              if (storeLink.isNotEmpty &&
                  await canLaunchUrl(Uri.parse(storeLink))) {
                await launchUrlString(storeLink,
                    mode: LaunchMode.externalApplication);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
              ref.read(showOptionalUpdateDialogProvider.notifier).state = false;
              _navigateTo(route);
            },
            child: Text('Update'.tr),
          ),
        ],
      ),
    );
  }
}

/// Full-screen "Update required" when app is below minimum version.
class _UpdateRequiredBody extends StatelessWidget {
  const _UpdateRequiredBody({required this.storeLink});

  final String storeLink;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoWidget(),
            const SizedBox(height: 32),
            Text(
              'Update required'.tr,
              style: AppFont.font24w600Black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Update required message'.tr,
              style: AppFont.font14W500Black,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (storeLink.isNotEmpty &&
                      await canLaunchUrl(Uri.parse(storeLink))) {
                    await launchUrlString(storeLink,
                        mode: LaunchMode.externalApplication);
                  }
                },
                child: Text('Update'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
