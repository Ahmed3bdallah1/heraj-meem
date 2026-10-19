part of '../../add_ad_screen.dart';

class _AddAdPhotoBox extends StatelessWidget {
  const _AddAdPhotoBox({
    required this.photos,
    required this.onRemoveImage,
  });

  final ValueNotifier<List<AddAdPhoto>> photos;
  final ValueChanged<int> onRemoveImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColor.primary2.withAlpha(100),
        border: Border.all(color: AppColor.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ValueListenableBuilder<List<AddAdPhoto>>(
        valueListenable: photos,
        builder: (context, images, _) {
          if (images.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 48, color: AppColor.grey2),
                const Gap(8),
                Text(
                  'Maximum limit: 20 photos'.tr,
                  style: AppFont.font12w400Black,
                ),
              ],
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _AddAdPhotoTile(
                path: images[index].path,
                onRemove: () => onRemoveImage(index),
              );
            },
          );
        },
      ),
    );
  }
}
