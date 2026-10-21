part of '../../add_ad_screen.dart';

class _AddAdContinueButton extends StatelessWidget {
  const _AddAdContinueButton({
    required this.step,
    required this.submitting,
    required this.isEditing,
    required this.onPressed,
  });

  final int step;
  final ValueNotifier<bool> submitting;
  final bool isEditing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: submitting,
      builder: (context, isSubmitting, _) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: CustomFilledButton(
            text: step == 2
                ? (isEditing ? 'Update Listing'.tr : 'Create New Ad'.tr)
                : 'Continue'.tr,
            isLoading: isSubmitting,
            radius: 12,
            onPressed: isSubmitting ? null : onPressed,
          ),
        );
      },
    );
  }
}
