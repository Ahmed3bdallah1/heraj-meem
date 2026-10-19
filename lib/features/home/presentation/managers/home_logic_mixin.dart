import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:heraj_meem/features/home/presentation/managers/baho_feed_provider.dart';
import 'package:heraj_meem/features/home/presentation/view/home_screen.dart';

mixin HomeLogicMixin on ConsumerState<HomeScreen> {
  Future<void> onRefresh() async {
    ref.invalidate(bahoCategoriesProvider);
    ref.invalidate(bahoFeaturedAdsProvider);
    ref.invalidate(bahoAdsProvider);
  }
}
