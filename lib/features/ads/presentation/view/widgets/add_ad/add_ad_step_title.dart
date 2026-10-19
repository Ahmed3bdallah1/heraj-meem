part of '../../add_ad_screen.dart';

class _AddAdStepTitles extends ConsumerWidget {
  const _AddAdStepTitles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(addAdStepIndexProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(
          4,
          (index) => _AddAdStepTitle(
            index: index,
            filled: index <= step,
          ),
        ),
      ),
    );
  }
}
