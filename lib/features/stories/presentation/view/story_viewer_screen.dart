import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/ui/shared_widgets/loading_widget.dart';
import 'package:story_view/story_view.dart';
import '../../../../../config/app_font.dart';
import '../../../../../core/service/localization_service/localization_service.dart';
import '../../../../../main.dart';
import '../../domain/entities/story_entity.dart';
import '../../domain/use_case/view_story_use_case.dart';
import 'package:heraj_meem/features/categories/presentation/view/category_screen.dart';
import 'package:heraj_meem/features/categories/data/models/main_category_model.dart';
import 'package:heraj_meem/features/store/presentation/view/store_category_screen.dart';
import 'package:heraj_meem/features/products/presentation/view/product_details_screen.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryEntity> stories;
  final int initialStoryIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialStoryIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late StoryController controller;
  List<StoryItem> storyItems = [];
  int currentStoryIndex = 0;
  Key _storyViewKey = UniqueKey();
  final Set<String> _viewedStoryIds = {};
  late final ViewStoryUseCase _viewStoryUseCase;

  @override
  void initState() {
    super.initState();
    controller = StoryController();
    currentStoryIndex =
        widget.initialStoryIndex.clamp(0, widget.stories.length - 1);
    _viewStoryUseCase = getIt<ViewStoryUseCase>();
    _loadStoryItems();
    _markStoryAsViewed();
  }

  void _markStoryAsViewed() {
    if (currentStoryIndex >= widget.stories.length) return;

    final story = widget.stories[currentStoryIndex];
    for (final item in story.items) {
      if (item.storyId.isNotEmpty && !_viewedStoryIds.contains(item.storyId)) {
        _viewedStoryIds.add(item.storyId);
        _viewStoryUseCase.call(item.storyId).then((result) {
          result.fold(
            (failure) {
              debugPrint('Failed to mark story as viewed: ${failure.message}');
            },
            (_) {},
          );
        });
      }
    }
  }

  void _loadStoryItems() {
    if (currentStoryIndex >= widget.stories.length) {
      Navigator.of(context).pop();
      return;
    }

    final story = widget.stories[currentStoryIndex];
    final isRTL = localeService.isArabic;
    storyItems = story.items.map((item) {
      final captionWidget = Text(
        item.caption ?? '',
        style: AppFont.font16W600NearlyWhite,
        textAlign: isRTL ? TextAlign.right : TextAlign.left,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      );

      if (item.mediaType == StoryMediaType.image) {
        return StoryItem.pageImage(
          url: item.mediaUrl,
          controller: controller,
          caption: captionWidget,
          duration: item.duration,
        );
      } else {
        return StoryItem.pageVideo(
          item.mediaUrl,
          controller: controller,
          caption: captionWidget,
          duration: item.duration,
        );
      }
    }).toList();

    setState(() {});
    _markStoryAsViewed();
  }

  void _onStoryComplete() {
    if (currentStoryIndex < widget.stories.length - 1) {
      controller.pause();

      setState(() {
        currentStoryIndex++;
        _storyViewKey = UniqueKey();
        _loadStoryItems();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.play();
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onVerticalSwipeComplete(Direction? direction) {
    if (direction == Direction.down) {
      Navigator.of(context).pop();
    }
  }

  void _goToNextStory() {
    if (currentStoryIndex < widget.stories.length - 1) {
      controller.pause();
      setState(() {
        currentStoryIndex++;
        _storyViewKey = UniqueKey();
        _loadStoryItems();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.play();
        }
      });
    }
  }

  void _goToPreviousStory() {
    if (currentStoryIndex > 0) {
      controller.pause();
      setState(() {
        currentStoryIndex--;
        _storyViewKey = UniqueKey();
        _loadStoryItems();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller.play();
        }
      });
    }
  }

  void _handleLinkNavigation() {
    if (currentStoryIndex >= widget.stories.length) return;

    final story = widget.stories[currentStoryIndex];
    StoryItemEntity? itemWithLink;
    try {
      itemWithLink = story.items.firstWhere(
        (item) =>
            item.linkType != null &&
            item.linkType != 'none' &&
            item.linkId != null &&
            item.linkId!.isNotEmpty,
      );
    } catch (e) {
      return;
    }

    if (itemWithLink.linkType == null ||
        itemWithLink.linkType == 'none' ||
        itemWithLink.linkId == null ||
        itemWithLink.linkId!.isEmpty) {
      return;
    }

    final linkType = itemWithLink.linkType!;
    final linkId = itemWithLink.linkId!;

    controller.pause();
    Navigator.of(context).pop();

    switch (linkType.toLowerCase()) {
      case 'product':
        Get.to(() => ProductDetailsScreen(productId: linkId));
        break;
      case 'category':
        final category = CategoryModel(
          id: linkId,
          name: story.userName,
          nameTr: story.userName,
          nameAr: story.userName,
          slug: '',
          level: 1,
          order: 0,
          isActive: true,
          createdAt: '',
          updatedAt: '',
          v: 0,
        );
        Get.to(() => CategoryScreen(category: category));
        break;
      case 'admincategory':
        final category = CategoryModel(
          id: linkId,
          name: story.userName,
          nameTr: story.userName,
          nameAr: story.userName,
          slug: '',
          level: 1,
          order: 0,
          isActive: true,
          createdAt: '',
          updatedAt: '',
          v: 0,
        );
        Get.to(() => StoreCategoryScreen(category));
        break;
      default:
        break;
    }
  }

  bool _hasValidLink() {
    if (currentStoryIndex >= widget.stories.length) return false;

    final story = widget.stories[currentStoryIndex];
    return story.items.any(
      (item) =>
          item.linkType != null &&
          item.linkType != 'none' &&
          item.linkId != null &&
          item.linkId!.isNotEmpty,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (storyItems.isEmpty) {
      return const Scaffold(
        body: Center(child: LoadingWidget()),
      );
    }

    final currentStory = widget.stories[currentStoryIndex];
    final isRTL = !localeService.isArabic;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragEnd: (details) {
            final velocity = details.velocity.pixelsPerSecond.dx;
            final threshold = 150.0;

            if (velocity.abs() > threshold) {
              controller.pause();

              if (isRTL) {
                if (velocity > 0) {
                  _goToPreviousStory();
                } else {
                  _goToNextStory();
                }
              } else {
                if (velocity > 0) {
                  _goToNextStory();
                } else {
                  _goToPreviousStory();
                }
              }
            } else {
              controller.play();
            }
          },
          child: Stack(
            children: [
              Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: KeyedSubtree(
                  key: _storyViewKey,
                  child: StoryView(
                    storyItems: storyItems,
                    controller: controller,
                    onComplete: _onStoryComplete,
                    onVerticalSwipeComplete: _onVerticalSwipeComplete,
                    indicatorColor: AppColor.grey1,
                    indicatorForegroundColor: AppColor.primary,
                    progressPosition: ProgressPosition.top,
                    repeat: false,
                    inline: false,
                  ),
                ),
              ),
              if (_hasValidLink())
                SafeArea(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20, right: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(75),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleLinkNavigation,
                            borderRadius: BorderRadius.circular(30),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const Gap(8),
                                  Text(
                                    "View".tr,
                                    style: AppFont.font16W600Black.copyWith(
                                      color: Colors.white,
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
                ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    textDirection:
                        isRTL ? TextDirection.rtl : TextDirection.ltr,
                    children: isRTL
                        ? [
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Text(
                                        currentStory.userName,
                                        style: AppFont.font16W700Black.copyWith(
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      if (currentStory.isAdmin) ...[
                                        const Gap(6),
                                        Icon(
                                          Icons.workspace_premium,
                                          size: 18,
                                          color: AppColor.primary,
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    currentStory.isAdmin
                                        ? 'Official'.tr
                                        : 'Vendor'.tr,
                                    style: AppFont.font12w500Grey2.copyWith(
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(12),
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  currentStory.userImageUrl.isNotEmpty
                                      ? NetworkImage(currentStory.userImageUrl)
                                      : null,
                              child: currentStory.userImageUrl.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                          ]
                        : [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  currentStory.userImageUrl.isNotEmpty
                                      ? NetworkImage(currentStory.userImageUrl)
                                      : null,
                              child: currentStory.userImageUrl.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        currentStory.userName,
                                        style: AppFont.font16W700Black.copyWith(
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                      if (currentStory.isAdmin) ...[
                                        const Gap(6),
                                        FaIcon(
                                          FontAwesomeIcons.chessKing,
                                          size: 14,
                                          color: AppColor.primary,
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    currentStory.isAdmin
                                        ? 'Official'.tr
                                        : 'Vendor'.tr,
                                    style: AppFont.font12W700Primary.copyWith(
                                      color: currentStory.isAdmin
                                          ? AppColor.primary.withAlpha(150)
                                          : Colors.white70,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
