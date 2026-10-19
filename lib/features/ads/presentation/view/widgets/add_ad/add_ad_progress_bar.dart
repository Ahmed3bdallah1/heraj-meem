part of '../../add_ad_screen.dart';

class _AddAdProgressBar extends ConsumerWidget {
  const _AddAdProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(addAdStepIndexProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: List.generate(
          4,
          (index) => _AddAdProgressSegment(
            filled: index <= step,
            showGap: index < 3,
          ),
        ),
      ),
    );
  }
}
