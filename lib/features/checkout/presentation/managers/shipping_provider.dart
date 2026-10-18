import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../../shipping/data/data_source/shipping_data_source.dart';
import '../../../shipping/data/models/shipping_model.dart';
import '../../../address/presentation/manager/address_provider.dart';
import '../../../cart/presentation/manager/fetch_cart_provider.dart';
import 'selection_providers.dart';

final selectedShippingCompanyProvider = StateProvider<ShippingCompanyModel?>((ref) => null);

final shippingCompaniesProvider = FutureProvider.autoDispose<List<ShippingCompanyModel>>((ref) async {
  final dataSource = getIt<ShippingDataSource>();
  try {
    return await dataSource.getShippingCompanies();
  } catch (e) {
    return [];
  }
});

final calculatedShippingProvider = FutureProvider.autoDispose<List<ShippingCompanyModel>>((ref) async {
  final selectedAddressId = ref.watch(selectedAddressIdProvider);
  final cartAsync = ref.watch(fetchCartProvider);
  
  if (selectedAddressId == null) {
    return [];
  }
  
  final addressesAsync = ref.watch(fetchAddressesProvider);
  final addresses = addressesAsync.valueOrNull ?? [];
  final selectedAddress = addresses.firstWhere(
    (a) => a.id == selectedAddressId,
    orElse: () => addresses.isNotEmpty ? addresses.first : throw Exception('No address found'),
  );
  
  // Calculate subtotal
  final items = cartAsync.valueOrNull?.items ?? [];
  final subtotal = items.fold(0.0, (p, e) => p + (e.subtotal ?? 0.0));
  
  // Get country code and province code from address
  // Default to TR (Turkey) if country is not specified
  final countryCode = 'TR'; // You may need to map country name to code
  // Use cityCode if available, otherwise try postalCode first 2 digits, or default
  final provinceCode = selectedAddress.cityCode ?? 
                       (selectedAddress.postalCode != null && selectedAddress.postalCode!.length >= 2
                           ? selectedAddress.postalCode!.substring(0, 2)
                           : '34'); // Default to Istanbul code
  
  final dataSource = getIt<ShippingDataSource>();
  try {
    final companies = await dataSource.calculateShipping(
      countryCode: countryCode,
      provinceCode: provinceCode,
      orderTotal: subtotal,
    );
    
    // Auto-select first company if none selected
    if (companies.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedShippingCompanyProvider.notifier).state = companies.first;
      });
    }
    
    return companies;
  } catch (e) {
    return [];
  }
});

