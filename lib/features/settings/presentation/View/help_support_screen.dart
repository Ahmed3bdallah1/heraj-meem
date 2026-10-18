import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/ui/shared_widgets/scaffold_back_ground.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_filled_button.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldBackGround(
      title: 'Help & Support'.tr,
      isRoot: false,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom,
          left: 20,
          right: 20,
        ),
        child: CustomFilledButton(
          text: "Ok".tr,
          fontColor: Colors.white,
          color: AppColor.primary,
          onPressed: () => Get.back(),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support Contact Section
            _ContactSection(
              title: 'Customer Support'.tr,
              icon: Icons.support_agent,
              color: AppColor.primary,
              contacts: [
                _ContactItem(
                  icon: Icons.email_outlined,
                  label: 'Email'.tr,
                  value: 'support@esyasatgo.com',
                  onTap: () => _launchEmail('support@esyasatgo.com'),
                ),
                _ContactItem(
                  icon: Icons.language_outlined,
                  label: 'Website'.tr,
                  value: 'www.esyasatgo.com',
                  onTap: () => _launchUrl('https://esyasatgo.com'),
                ),
                _ContactItem(
                  icon: Icons.phone_outlined,
                  label: 'Phone'.tr,
                  value: 'Contact us through the app'.tr,
                  onTap: null,
                ),
              ],
            ),
            const Gap(24),
            // Admin Contact Section
            _ContactSection(
              title: 'Admin Contact'.tr,
              icon: Icons.admin_panel_settings_outlined,
              color: AppColor.primaryDark,
              contacts: [
                _ContactItem(
                  icon: Icons.email_outlined,
                  label: 'Admin Email'.tr,
                  value: 'admin@esyasatgo.com',
                  onTap: () => _launchEmail('admin@esyasatgo.com'),
                ),
                _ContactItem(
                  icon: Icons.business_outlined,
                  label: 'Business Inquiries'.tr,
                  value: 'business@esyasatgo.com',
                  onTap: () => _launchEmail('business@esyasatgo.com'),
                ),
              ],
            ),
            const Gap(24),
            _HelpInfoSection(),
            Gap(MediaQuery.of(context).padding.bottom + 40),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request&body=This is a support request.',
    );
    if (await canLaunchUrlString(emailUri.toString())) {
      await launchUrlString(emailUri.toString());
    } else {
      Get.snackbar(
        'Error'.tr,
        'Could not open email client'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error'.tr,
        'Could not open website'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _ContactSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_ContactItem> contacts;

  const _ContactSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  title,
                  style: AppFont.font18W700Black,
                ),
              ),
            ],
          ),
          const Gap(20),
          ...contacts.map((contact) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: contact,
              )),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap != null ? AppColor.primaryWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColor.grey1,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: onTap != null ? AppColor.primary : AppColor.grey2,
              size: 24,
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppFont.font12w500Grey2,
                  ),
                  const Gap(4),
                  Text(
                    value,
                    style: AppFont.font14W600Black,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColor.grey2,
              ),
          ],
        ),
      ),
    );
  }
}

class _HelpInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.green.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: AppColor.green,
                  size: 24,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  'How Can We Help?'.tr,
                  style: AppFont.font18W700Black,
                ),
              ),
            ],
          ),
          const Gap(20),
          _InfoItem(
            icon: Icons.info_outline,
            text:
                'For technical support, account issues, or general inquiries, please contact our support team.'
                    .tr,
          ),
          const Gap(12),
          _InfoItem(
            icon: Icons.business_center_outlined,
            text:
                'For business partnerships, advertising, or administrative matters, please contact the admin team.'
                    .tr,
          ),
          const Gap(12),
          _InfoItem(
            icon: Icons.access_time_outlined,
            text:
                'Our support team typically responds within 24-48 hours during business days.'
                    .tr,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColor.primary,
          size: 20,
        ),
        const Gap(12),
        Expanded(
          child: Text(
            text,
            style: AppFont.font14W500Black.copyWith(
              color: AppColor.grey2,
            ),
          ),
        ),
      ],
    );
  }
}
