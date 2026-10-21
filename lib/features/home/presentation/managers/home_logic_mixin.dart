import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/home/presentation/view/home_screen.dart';

mixin HomeLogicMixin on ConsumerState<HomeScreen> {
  Future<void> onRefresh() async {
    ref.invalidate(bahoCategoriesProvider);
    ref.invalidate(bahoFeaturedAdsProvider);
    ref.invalidate(bahoAdsProvider);
  }

  bool onAdsScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification is! ScrollUpdateNotification &&
        notification is! ScrollEndNotification &&
        notification is! ScrollMetricsNotification) {
      return false;
    }
    final metrics = notification.metrics;
    final nearEnd = metrics.maxScrollExtent <= 0 ||
        metrics.pixels >= metrics.maxScrollExtent - 240;
    if (!nearEnd) return false;
    ref.read(bahoAdsProvider.notifier).fetchNextPage();
    return false;
  }
}
