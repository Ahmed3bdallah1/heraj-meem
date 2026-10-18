import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/config/app_font.dart';
import '../../../../address/presentation/manager/address_provider.dart';
import '../../managers/selection_providers.dart';

class AddressSelector extends ConsumerWidget {
  const AddressSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(fetchAddressesProvider);
    final selectedId = ref.watch(selectedAddressIdProvider);
    return addressesAsync.when(
      data: (addresses) {
        if (addresses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('No addresses. Add a new address'),
          );
        }
        return Column(
          children: addresses.map((a) {
            return Card(
              color: AppColor.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: RadioListTile<String>(
                value: a.id,
                groupValue: selectedId,
                onChanged: (val) {
                  ref.read(selectedAddressIdProvider.notifier).state = val;
                },
                title: Text(a.fullName),
                subtitle: Text(
                    '${a.addressLine1}${a.addressLine2 != null ? ', ${a.addressLine2}' : ''}${a.city != null ? ', ${a.city}' : ''}'),
                activeColor: AppColor.primary,
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Text('Failed to load addresses'),
    );
  }
}
