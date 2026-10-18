import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/features/stories/domain/entities/story_entity.dart';
import 'package:heraj/helper/riverpod.dart';
import 'package:heraj/models/user_model.dart';
import '../../../../../config/app_font.dart';
import '../../../../../core/service/auth_service.dart';
import '../../../../../core/service/local_data_manager.dart';
import '../../../../../ui/shared_widgets/custom_image_circle.dart';
import '../../../../stories/presentation/view/story_viewer_screen.dart';
import '../../../../stories/presentation/view/add_story_screen.dart';
import '../../../../plans/presentation/view/plans_screen.dart';
import '../../../../plans/presentation/managers/plans_provider.dart';
import '../../managers/fetch_home_data_provider.dart';

class StoriesAdsSection extends ConsumerWidget {
  const StoriesAdsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider) ?? dataManager.getUser();
    final homeDataProvider = ref.watch(fetchHomeDataProvider);

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: homeDataProvider.customWhen(
        ref: ref,
        refreshable: fetchHomeDataProvider.future,
        data: (homeData) {
          final stories = homeData.stories;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: false,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _UserStoryItem(user: user!);
              }
              if (index <= stories.length) {
                final storyIndex = index - 1;
                final story = stories[storyIndex];
                return _StoryItem(
                  story: story,
                  onTap: () {
                    Get.to(() => StoryViewerScreen(
                          stories: stories,
                          initialStoryIndex: storyIndex,
                        ));
                  },
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
        loading: () => _buildLoadingStories(),
        error: (e, st) => _buildLoadingStories(),
      ),
    );
  }

  Widget _buildLoadingStories() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: false,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.grey1,
                  ),
                ),
                const Gap(4),
                Container(
                  height: 12,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColor.grey1,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UserStoryItem extends ConsumerWidget {
  final UserModel user;

  const _UserStoryItem({required this.user});

  Future<void> _handleUploadStory(BuildContext context, WidgetRef ref) async {
    Get.to(() => const AddStoryScreen());
    // try {
    //   final subscriptionAsync = await ref.read(fetchMySubscriptionProvider.future);
    //
    //   if (subscriptionAsync.currentSubscription == null) {
    //     Get.to(() => const PlansScreen());
    //   } else {
    //     Get.to(() => const AddStoryScreen());
    //   }
    // } catch (e) {
    //   Get.to(() => const PlansScreen());
    // }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _handleUploadStory(context, ref),
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColor.primary, width: 2),
                  ),
                  child: ClipOval(
                    child: CustomImageCircle(
                      image: user.image ?? "",
                      radius: 38,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(4),
            Text(
              user.name,
              style: AppFont.font12w400Black,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryItem extends StatefulWidget {
  final StoryEntity story;
  final VoidCallback onTap;

  const _StoryItem({
    required this.story,
    required this.onTap,
  });

  @override
  State<_StoryItem> createState() => _StoryItemState();
}

class _StoryItemState extends State<_StoryItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.story.isAdmin) {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..repeat();
      _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.linear,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (widget.story.isAdmin) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnseenStories = widget.story.items.isNotEmpty;
    final isAdmin = widget.story.isAdmin;

    if (isAdmin) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 60,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColor.primary,
                          Colors.purple,
                          AppColor.primary,
                        ],
                        stops: [
                          0.0,
                          0.5 + (_animation.value * 0.3),
                          1.0,
                        ],
                        begin: Alignment(
                          -1 + (_animation.value * 2),
                          -1,
                        ),
                        end: Alignment(
                          1 - (_animation.value * 2),
                          1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: ClipOval(
                              child: widget.story.userImageUrl.isNotEmpty
                                  ? Image.network(
                                      widget.story.userImageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: AppColor.grey1,
                                          child: const Icon(Icons.person),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: AppColor.grey1,
                                      child: const Icon(Icons.person),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Gap(4),
              Text(
                widget.story.userName,
                style: AppFont.font12w400Black,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasUnseenStories
                    ? LinearGradient(
                        colors: [AppColor.primary, Colors.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: hasUnseenStories
                    ? null
                    : Border.all(color: AppColor.grey1, width: 2),
              ),
              padding:
                  hasUnseenStories ? const EdgeInsets.all(3) : EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasUnseenStories ? Colors.white : Colors.transparent,
                ),
                child: ClipOval(
                  child: widget.story.userImageUrl.isNotEmpty
                      ? Image.network(
                          widget.story.userImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColor.grey1,
                              child: const Icon(Icons.person),
                            );
                          },
                        )
                      : Container(
                          color: AppColor.grey1,
                          child: const Icon(Icons.person),
                        ),
                ),
              ),
            ),
            const Gap(4),
            Text(
              widget.story.userName,
              style: AppFont.font12w400Black,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
