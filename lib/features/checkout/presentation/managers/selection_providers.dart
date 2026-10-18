import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'payment_type.dart';

final selectedAddressIdProvider = StateProvider<String?>((ref) => null);

final selectedPaymentProvider =
    StateProvider<PaymentType>((ref) => PaymentType.Cash);
