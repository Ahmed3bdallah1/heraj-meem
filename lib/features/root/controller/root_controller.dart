import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view/root_view.dart';

final homeViewIndex = StateProvider((ref)=> 0);

final rootIndex = StateNotifierProvider.autoDispose<RootController, int>((ref) {
  ref.listenSelf((previous, next) {
    ref.invalidate(hideNavBarProvider);
  });
  return RootController();
});

class RootController extends StateNotifier<int> {
  RootController() : super(0);
  Map<String, dynamic>? args;

  bool isSelectedIndex(int index) {
    return state == index;
  }

  NavBarItem getHomeScreenCategory() {
    return NavBarItem.values[state];
  }

  goBack() {
    state = 0;
  }

  reset() {
    state = 0;
  }

  setSelectedIndex(int index, {Map<String, dynamic>? args}) {
    if (state == index) {
      state = -1;
    }
    this.args = args;
    state = index;
  }

  setSelectedCat(NavBarItem item, {Map<String, dynamic>? args}) {
    if (state == item.index) {
      state = -1;
    }
    this.args = args;
    state = item.index;
  }
}

enum NavBarItem {
  home,
  shipments,
  reports,
  settings,
}
