import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OrderByTypes {
  Newest("newest","-updatedAt"),
  Oldest("oldest","-createdAt");

  final String sortValue;
  final String value;

  const OrderByTypes(this.sortValue,this.value);
}

final searchFilterProvider = StateNotifierProvider<SearchFilterNotifier, Map<String, dynamic>>(
        (ref) => SearchFilterNotifier());

class SearchFilterNotifier extends StateNotifier<Map<String, dynamic>> {
  SearchFilterNotifier()
      : super({
    "limit": 20,
    'minPrice': null,
    'maxPrice': null,
    "sort": null,
    'name': null,
    'category': null,
    'city': null,
    'condition': null,
    'featured': null,
  });

  void updateFilter(String key, dynamic value) {
    state = {...state, key: value};
  }

  void clearFilters() {
    state = {
      'minPrice': null,
      'maxPrice': null,
      'featured': null,
      "sort": null,
      'search': null,
      'name': null,
      'category': null,
      'city': null,
      'condition': null,
    };
  }
  
  int getActiveFiltersCount() {
    return state.entries.where((element) {
      if (element.key == 'limit' || element.key == 'name' || element.key == 'sort') {
        return false;
      }
      return element.value != null;
    }).length;
  }
}
