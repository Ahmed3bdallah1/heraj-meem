part of '../../my_ads_screen.dart';

class _MyAdTile extends StatefulWidget {
  const _MyAdTile({
    super.key,
    required this.index,
    required this.product,
    required this.onPublish,
  });

  final int index;
  final ProductModel product;
  final VoidCallback onPublish;

  @override
  State<_MyAdTile> createState() => _MyAdTileState();
}

class _MyAdTileState extends State<_MyAdTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  var _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = curved;
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curved);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    final delay = widget.index.clamp(0, 6) * 45;
    Future<void>.delayed(Duration(milliseconds: delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final image = product.thumbImage ??
        (product.images.isNotEmpty ? product.images.first : '');
    final price = product.hasListedPrice
        ? '${product.afterPrice ?? ''} ${'SAR'.tr}'
        : 'Contact the publisher'.tr;
    final age = adAgeLabel(product.createdAt);
    final isDraft = product.status.toUpperCase() == 'DRAFT';

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColor.black.withAlpha(18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Get.to(
                  () => AdDetailsScreen(productId: product.id, mine: true),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AdImage(
                        url: image,
                        label: _statusLabel(product.status),
                        color: _statusColor(product.status),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppFont.font16W600Black,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(8),
                            Text(
                              price,
                              style: AppFont.font16W700Black.copyWith(
                                color: AppColor.primary,
                              ),
                            ),
                            const Gap(8),
                            Row(
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 16,
                                  color: AppColor.grey2,
                                ),
                                const Gap(4),
                                Text(
                                  '${product.views}',
                                  style: AppFont.font12w500Grey2,
                                ),
                                if (age.isNotEmpty) ...[
                                  const Gap(12),
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: AppColor.grey2,
                                  ),
                                  const Gap(4),
                                  Expanded(
                                    child: Text(
                                      age,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFont.font12w500Grey2,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (isDraft) ...[
                              const Gap(12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return CustomFilledButton(
                                    width: constraints.maxWidth,
                                    height: 48,
                                    radius: 12,
                                    text: 'Publish'.tr,
                                    widget: const Icon(
                                      Icons.campaign_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: widget.onPublish,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdImage extends StatelessWidget {
  const _AdImage({
    required this.url,
    required this.label,
    required this.color,
  });

  final String url;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 112,
        height: 112,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: AppColor.primary2,
              child: url.isEmpty
                  ? Icon(Icons.image_outlined, color: AppColor.grey2)
                  : ImageOrSvg(url, width: 112, height: 112, fit: BoxFit.cover),
            ),
            PositionedDirectional(
              top: 8,
              start: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: AppFont.font12W600Primary.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status.toUpperCase()) {
    case 'ACTIVE':
    case 'APPROVED':
      return 'Active'.tr;
    case 'PENDING':
    case 'PENDING_REVIEW':
      return 'Pending Review'.tr;
    case 'EXPIRED':
      return 'Expired'.tr;
    case 'DRAFT':
      return 'Draft'.tr;
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status.toUpperCase()) {
    case 'ACTIVE':
    case 'APPROVED':
      return AppColor.primary;
    case 'PENDING':
    case 'PENDING_REVIEW':
      return const Color(0xffE39B00);
    case 'EXPIRED':
      return AppColor.danger;
    default:
      return AppColor.grey2;
  }
}
