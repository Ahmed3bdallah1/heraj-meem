import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:heraj/features/store/presentation/view/widgets/all_top_stores/store_card.dart';
import '../../../../config/app_font.dart';
import '../managers/stores_provider.dart';

class AllTopStoresScreen extends ConsumerStatefulWidget {
  const AllTopStoresScreen({super.key});

  @override
  ConsumerState<AllTopStoresScreen> createState() => _AllTopStoresScreenState();
}

class _AllTopStoresScreenState extends ConsumerState<AllTopStoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'topRated'; // topRated, mostProducts, newest

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 3.5,
                    colors: [
                      Colors.white,
                      AppColor.primary.withAlpha(30), // Light orange
                    ],
                    // stops: const [0.0, 0.],
                  ),
                ),
                child: Column(
                  children: [
                    // Back button and Icon
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Get.back(),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const Gap(8),

                    // Store Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.local_shipping,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(16),

                    // Title
                    Text(
                      'Discover All Stores'.tr,
                      style: AppFont.font20W700Black.copyWith(
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(8),

                    // Subtitle
                    Text(
                      'Browse through our verified sellers and find the best products from trusted businesses'
                          .tr,
                      style: AppFont.font14W500Black.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(20),

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref
                            .read(storesFilterProvider.notifier)
                            .updateSearch(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search stores by name...'.tr,
                        hintStyle: AppFont.font14W500Black.copyWith(
                          color: Colors.grey[400],
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[700]),
                          onPressed: () {
                            ref
                                .read(storesFilterProvider.notifier)
                                .updateSearch(null);
                            _searchController.clear();
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const Gap(20),

                    // Stats
                    Consumer(
                      builder: (context, ref, child) {
                        final storesAsync = ref.watch(storesNotifierProvider);
                        return storesAsync.when(
                          data: (storePaginated) => Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '${storePaginated.data.length}',
                                      style: AppFont.font20W700Black.copyWith(
                                        color: const Color(0xFFFF9800),
                                        fontSize: 32,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      'Total Stores'.tr,
                                      style: AppFont.font14W500Black.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.grey[300],
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '100%',
                                      style: AppFont.font20W700Black.copyWith(
                                        color: const Color(0xFF4CAF50),
                                        fontSize: 32,
                                      ),
                                    ),
                                    const Gap(4),
                                    Text(
                                      'Trusted Sellers'.tr,
                                      style: AppFont.font14W500Black.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          loading: () => const Gap(80),
                          error: (_, __) => const Gap(80),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Filter Tabs
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        icon: Icons.star,
                        label: 'Top Rated'.tr,
                        isSelected: _selectedFilter == 'topRated',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'topRated';
                          });
                        },
                      ),
                      const Gap(8),
                      _FilterChip(
                        icon: Icons.trending_up,
                        label: 'Most Products'.tr,
                        isSelected: _selectedFilter == 'mostProducts',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'mostProducts';
                          });
                        },
                      ),
                      const Gap(8),
                      _FilterChip(
                        icon: Icons.access_time,
                        label: 'Newest'.tr,
                        isSelected: _selectedFilter == 'newest',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'newest';
                          });
                        },
                      ),
                      const Gap(8),
                      _FilterChip(
                        icon: Icons.list,
                        label: 'All'.tr,
                        isSelected: _selectedFilter == 'all',
                        onTap: () {
                          setState(() {
                            _selectedFilter = 'all';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stores List with Consumer
            Consumer(
              builder: (context, ref, child) {
                final storesAsync = ref.watch(storesNotifierProvider);

                return storesAsync.when(
                  data: (storePaginated) {
                    if (storePaginated.data.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.store_outlined,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const Gap(16),
                              Text(
                                'No stores found'.tr,
                                style: AppFont.font18W700Black.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverMainAxisGroup(
                      slivers: [
                        // Showing count
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Showing ${storePaginated.data.length} of ${storePaginated.data.length} stores',
                              style: AppFont.font14W500Black.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),

                        // Stores List
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final store = storePaginated.data[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        index < storePaginated.data.length - 1
                                            ? 16
                                            : 0,
                                  ),
                                  child: StoreCard(store: store),
                                );
                              },
                              childCount: storePaginated.data.length,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFFFF9800),
                          ),
                          const Gap(16),
                          Text(
                            'Loading stores...'.tr,
                            style: AppFont.font14W500Black.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  error: (error, _) => SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const Gap(16),
                          Text(
                            'Error loading stores'.tr,
                            style: AppFont.font18W700Black.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const Gap(8),
                          Text(
                            error.toString(),
                            style: AppFont.font12W400Grey1,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF9800) : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9800) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            const Gap(6),
            Text(
              label,
              style: AppFont.font14W600Black.copyWith(
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
