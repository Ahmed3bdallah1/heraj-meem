import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/config/app_font.dart';
import 'package:story_view/story_view.dart';
import '../../domain/entities/story_entity.dart';

class StoryViewerState {
  final int currentStoryIndex;
  final List<StoryItem> storyItems;
  final bool isLoading;

  StoryViewerState({
    required this.currentStoryIndex,
    required this.storyItems,
    this.isLoading = false,
  });

  StoryViewerState copyWith({
    int? currentStoryIndex,
    List<StoryItem>? storyItems,
    bool? isLoading,
  }) {
    return StoryViewerState(
      currentStoryIndex: currentStoryIndex ?? this.currentStoryIndex,
      storyItems: storyItems ?? this.storyItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StoryViewerNotifier extends StateNotifier<StoryViewerState> {
  final List<StoryEntity> stories;
  final int initialStoryIndex;

  StoryViewerNotifier({
    required this.stories,
    this.initialStoryIndex = 0,
  }) : super(StoryViewerState(
          currentStoryIndex: initialStoryIndex,
          storyItems: [],
          isLoading: true,
        )) {
    // Ensure initialStoryIndex is within bounds
    if (initialStoryIndex < 0 || initialStoryIndex >= stories.length) {
      state = state.copyWith(
        currentStoryIndex: 0,
        isLoading: false,
      );
      return;
    }
    _loadStoryItems();
  }

  void _loadStoryItems() {
    if (state.currentStoryIndex >= stories.length) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final story = stories[state.currentStoryIndex];
    final storyItems = story.items.map((item) {
      if (item.mediaType == StoryMediaType.image) {
        return StoryItem.pageImage(
          url: item.mediaUrl,
          controller: controller,
          caption: Text(
            item.caption ?? '',
            style: AppFont.font16W600NearlyWhite,
          ),
          duration: item.duration,
        );
      } else {
        return StoryItem.pageVideo(
          item.mediaUrl,
          controller: controller,
          caption: Text(
            item.caption ?? '',
            style: AppFont.font16W600NearlyWhite,
          ),
          duration: item.duration,
        );
      }
    }).toList();

    state = state.copyWith(
      storyItems: storyItems,
      isLoading: false,
    );
  }

  bool nextStory() {
    if (state.currentStoryIndex < stories.length - 1) {
      state = state.copyWith(
        currentStoryIndex: state.currentStoryIndex + 1,
        isLoading: true,
        storyItems: [],
      );
      _loadStoryItems();
      return true;
    }
    return false;
  }

  void previousStory() {
    if (state.currentStoryIndex > 0) {
      state = state.copyWith(
        currentStoryIndex: state.currentStoryIndex - 1,
        isLoading: true,
      );
      _loadStoryItems();
    }
  }

  final controller = StoryController();
}

final storyViewerProvider = StateNotifierProvider.family<StoryViewerNotifier,
    StoryViewerState, StoryViewerParams>(
  (ref, params) {
    final notifier = StoryViewerNotifier(
      stories: params.stories,
      initialStoryIndex: params.initialStoryIndex,
    );
    ref.onDispose(() {
      notifier.controller.dispose();
    });
    return notifier;
  },
);

class StoryViewerParams {
  final List<StoryEntity> stories;
  final int initialStoryIndex;
  final String sessionId;

  StoryViewerParams({
    required this.stories,
    this.initialStoryIndex = 0,
    String? sessionId,
  }) : sessionId =
            sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoryViewerParams &&
        other.initialStoryIndex == initialStoryIndex &&
        other.sessionId == sessionId &&
        other.stories.length == stories.length;
  }

  @override
  int get hashCode => Object.hash(initialStoryIndex, sessionId, stories.length);
}
