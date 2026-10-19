part of '../../add_ad_screen.dart';

class _AddAdCategoryTile extends StatelessWidget {
  const _AddAdCategoryTile({
    required this.category,
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final BahoCategory category;
  final String language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = bahoMediaUrl(category.imageUrl);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.primary2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColor.primary : AppColor.primary2,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: image.isEmpty
                  ? Icon(Icons.category, color: AppColor.primary)
                  : ImageOrSvg(
                      image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
            ),
            const Gap(8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                category.nameFor(language),
                style: AppFont.font12w400Black,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
