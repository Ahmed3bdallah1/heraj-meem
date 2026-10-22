import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj_meem/features/search/presentation/managers/baho_search_provider.dart';
import 'package:heraj_meem/features/search/presentation/view/baho_search_screen.dart';
import 'package:heraj_meem/ui/shared_widgets/search_shipments_text_field.dart';
import 'package:reactive_forms/reactive_forms.dart';

mixin BahoSearchActionsMixin on ConsumerState<BahoSearchScreen> {
  late final FormGroup form;
  late final FocusNode searchFocus;
  late final ScrollController scrollController;
  final _searchDelay = CustomDelay(milliseconds: 400);
  String _lastQuery = '';

  void initSearch(String query) {
    _lastQuery = query.trim();
    form = FormGroup({
      'query': FormControl<String>(value: query),
    });
    searchFocus = FocusNode();
    scrollController = ScrollController()..addListener(onResultsScroll);
  }

  void disposeSearch() {
    _searchDelay.cancel();
    scrollController
      ..removeListener(onResultsScroll)
      ..dispose();
    searchFocus.dispose();
    form.dispose();
  }

  void onQueryChanged(String raw) {
    _searchDelay.run(() => _runSearch(raw));
  }

  void submitSearch() {
    _searchDelay.cancel();
    searchFocus.unfocus();
    _runSearch((form.control('query').value ?? '').toString());
  }

  void _runSearch(String raw) {
    final query = raw.trim();
    if (query == _lastQuery) return;
    _lastQuery = query;
    ref.read(bahoSearchProvider(widget.query).notifier).search(query);
  }

  void onResultsScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels < position.maxScrollExtent - 240) return;
    ref.read(bahoSearchProvider(widget.query).notifier).fetchNextPage();
  }
}
