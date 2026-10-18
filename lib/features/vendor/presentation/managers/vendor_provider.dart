import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/products/data/models/product_model.dart';
import 'package:heraj/features/vendor/data/models/vendor_profile_model.dart';
import 'package:heraj/features/vendor/domain/use_case/get_my_products_use_case.dart';
import 'package:heraj/features/vendor/domain/use_case/get_vendor_profile_use_case.dart';
import '../../../../main.dart';

final fetchVendorProfileProvider =
    FutureProvider.autoDispose<VendorProfileModel>((ref) async {
  final useCase = getIt<GetVendorProfileUseCase>();
  final result = await useCase.call();
  return result.fold(
    (failure) => throw failure,
    (profile) => profile,
  );
});

final myProductsFilterProvider = StateNotifierProvider.autoDispose<
    MyProductsFilterNotifier, MyProductsFilter>((ref) {
  return MyProductsFilterNotifier();
});

class MyProductsFilter {
  final String? status;
  final int page;
  final int limit;
  final String? search;

  const MyProductsFilter({
    this.status,
    this.page = 1,
    this.limit = 20,
    this.search,
  });

  MyProductsFilter copyWith({
    String? status,
    int? page,
    int? limit,
    String? search,
  }) {
    return MyProductsFilter(
      status: status ?? this.status,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MyProductsFilter &&
        other.status == status &&
        other.page == page &&
        other.limit == limit &&
        other.search == search;
  }

  @override
  int get hashCode {
    return Object.hash(status, page, limit, search);
  }
}

class MyProductsFilterNotifier extends StateNotifier<MyProductsFilter> {
  MyProductsFilterNotifier() : super(MyProductsFilter());

  void setStatus(String? status) {
    state = state.copyWith(status: status, page: 1);
  }

  void setSearch(String search) {
    state = state.copyWith(search: search, page: 1);
  }

  void setPage(int page) {
    state = state.copyWith(page: page);
  }

  void reset() {
    state = MyProductsFilter();
  }
}

final fetchMyProductsProvider = FutureProvider.autoDispose
    .family<ProductPaginatedModel, MyProductsFilter>((ref, filter) async {
  final useCase = getIt<GetMyProductsUseCase>();
  final result = await useCase.call(
    GetMyProductsParams(
      status: filter.status,
      page: filter.page,
      limit: filter.limit,
      search: filter.search,
    ),
  );
  return result.fold(
    (failure) => throw failure,
    (products) => products,
  );
});
