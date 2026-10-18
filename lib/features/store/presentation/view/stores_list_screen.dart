import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/config/app_color.dart';
import 'package:heraj_meem/config/app_font.dart';
import 'package:heraj_meem/helper/riverpod.dart';
import 'package:heraj_meem/ui/shared_widgets/custom_app_bar.dart';
import 'package:heraj_meem/ui/shared_widgets/not_found_widget.dart';
import 'package:shimmer/shimmer.dart';
import '../managers/stores_provider.dart';
import 'widgets/store_tile.dart';

class StoresListScreen extends ConsumerStatefulWidget {
  const StoresListScreen({super.key});

  @override
  ConsumerState<StoresListScreen> createState() => _StoresListScreenState();
}

class _StoresListScreenState extends ConsumerState<StoresListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar2(title: "Stores".tr),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search stores...".tr,
                prefixIcon: Icon(Icons.search, color: AppColor.grey2),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColor.grey2),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(storesFilterProvider.notifier)
                              .updateSearch(null);
                          ref.invalidate(storesNotifierProvider);
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColor.nearlyWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      const BorderSide(color: AppColor.primary, width: 1.0),
                ),
              ),
              onChanged: (value) {
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                  ref
                      .read(storesFilterProvider.notifier)
                      .updateSearch(value.isEmpty ? null : value);
                  ref.invalidate(storesNotifierProvider);
                });
              },
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final storesAsync = ref.watch(storesNotifierProvider);
                final filter = ref.watch(storesFilterProvider);
                return storesAsync.customWhen(
                  ref: ref,
                  refreshable: fetchStoresFutureProvider(filter).future,
                  data: (storePaginated) {
                    if (storePaginated.data.isEmpty) {
                      return NotFoundWidget(
                        title: "No stores found".tr,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(storesNotifierProvider.notifier)
                            .refresh();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: storePaginated.data.length,
                        itemBuilder: (context, index) {
                          final store = storePaginated.data[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: StoreTile(
                              store: store,
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 280,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
