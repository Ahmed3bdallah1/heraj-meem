import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_outlined_button.dart';

class PublishAdConfirmationSheet extends StatefulWidget {
  const PublishAdConfirmationSheet({super.key, required this.onConfirm});

  final Future<bool> Function() onConfirm;

  static Future<void> show(
    BuildContext context, {
    required Future<bool> Function() onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PublishAdConfirmationSheet(onConfirm: onConfirm),
    );
  }

  @override
  State<PublishAdConfirmationSheet> createState() =>
      _PublishAdConfirmationSheetState();
}

class _PublishAdConfirmationSheetState extends State<PublishAdConfirmationSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _scale = Tween<double>(begin: 0.8, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
  );
  late final Animation<double> _fade = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  final submitting = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    submitting.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (submitting.value) return;
    submitting.value = true;
    final published = await widget.onConfirm();
    if (!mounted) return;
    submitting.value = false;
    if (published) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.scale(
            scale: _scale.value,
            child: SlideTransition(
              position: _slide,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColor.grey1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const Gap(24),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColor.primary.withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.campaign_outlined,
                            size: 40,
                            color: AppColor.primary,
                          ),
                        ),
                        const Gap(24),
                        Text(
                          'Publish this ad?'.tr,
                          style: AppFont.font20W700Black,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(12),
                        Text(
                          'This ad will be visible to everyone.'.tr,
                          style: AppFont.font14W500Black.copyWith(
                            color: AppColor.grey2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Gap(24),
                        ValueListenableBuilder<bool>(
                          valueListenable: submitting,
                          builder: (context, isSubmitting, _) {
                            return Row(
                              children: [
                                Expanded(
                                  child: CustomOutlinedButton(
                                    text: 'Cancel'.tr,
                                    textColor: AppColor.primary,
                                    onPressed: isSubmitting
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: CustomFilledButton(
                                    text: 'Publish'.tr,
                                    isLoading: isSubmitting,
                                    onPressed: isSubmitting ? null : _confirm,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
