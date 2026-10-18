import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/ui/shared_widgets/container_button.dart';
import '../../../../config/app_color.dart';
import '../../../../helper/responsive.dart';
import '../../../config/app_font.dart';
import '../../../ui/shared_widgets/custom_filled_button.dart';
import '../controller/onboarding_controller.dart';
import 'get_started_screen.dart';

class OnboardScreen extends ConsumerStatefulWidget {
  const OnboardScreen({super.key});

  @override
  ConsumerState<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends ConsumerState<OnboardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    final provider = ref.read(onboardListProvider);
    if (_currentPage < provider.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToGetStarted();
    }
  }

  void _goToGetStarted() {
    Get.offAll(() => const GetStartedScreen());
  }

  @override
  Widget build(BuildContext context) {
    responsiveInit(context);
    final provider = ref.watch(onboardListProvider);

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: provider.length,
            itemBuilder: (context, index) {
              final item = provider[index];
              return _OnboardingPage(
                image: item.image,
                title: item.title,
                subtitle: item.subTitle,
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: CustomFilteredButton(
              onTap: _goToGetStarted,
              color: Colors.white.withAlpha(25),
              widget: Text(
                'Skip'.tr,
                style: AppFont.font14W700White,
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 0,
            right: 0,
            child: _BottomNavigation(
              currentIndex: _currentPage,
              totalPages: provider.length,
              onNext: _nextPage,
              onFinish: _goToGetStarted,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String? image;
  final String? title;
  final String? subtitle;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (image != null)
          Image.asset(
            image!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: AppColor.backGround);
            },
          )
        else
          Container(color: AppColor.backGround),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(70),
                Colors.black.withAlpha(140),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(
                  flex: 3,
                ),
                Text(
                  (title ?? '').tr,
                  textAlign: TextAlign.center,
                  style: AppFont.font24w600Black.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(16),
                Text(
                  (subtitle ?? '').tr,
                  textAlign: TextAlign.center,
                  style: AppFont.font14W500Black.copyWith(
                    color: Colors.white.withAlpha(210),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerArrows extends StatefulWidget {
  const _ShimmerArrows();

  @override
  State<_ShimmerArrows> createState() => _ShimmerArrowsState();
}

class _ShimmerArrowsState extends State<_ShimmerArrows> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -5.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ShimmerArrow(
              icon: Icons.arrow_forward_ios,
              shimmerValue: _animation.value,
              delay: 0.0,
            ),
            _ShimmerArrow(
              icon: Icons.arrow_forward_ios,
              shimmerValue: _animation.value,
              delay: 0.3,
            ),
          ],
        );
      },
    );
  }
}

class _ShimmerArrow extends StatelessWidget {
  final IconData icon;
  final double shimmerValue;
  final double delay;

  const _ShimmerArrow({
    required this.icon,
    required this.shimmerValue,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final adjustedValue = (shimmerValue + delay).clamp(-1.0, 1.0);
    final opacity = (1.0 - (adjustedValue.abs() * 0.5)).clamp(0.3, 1.0);

    return Icon(
      icon,
      color: AppColor.primary.withOpacity(opacity),
      size: 15,
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _BottomNavigation({
    required this.currentIndex,
    required this.totalPages,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentIndex == totalPages - 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              totalPages,
              (index) => AnimatedContainer(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: currentIndex == index ? 18 : 8,
                width: 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.white
                      : Colors.white.withAlpha(125),
                  borderRadius: BorderRadius.circular(4),
                ), duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
          ContainerButton(
            widget: const _ShimmerArrows(),
            size: 56,
            onTap: isLastPage ? onFinish : onNext,
            color: AppColor.white,
            isCircle: true,
          ),
        ],
      ),
    );
  }
}
