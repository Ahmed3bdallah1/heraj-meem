import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../main.dart';
import '../../data/models/payment_model.dart';
import '../../domain/use_case/fetch_payments_use_case.dart';

final fetchPaymentsProvider = FutureProvider.autoDispose<PaymentPaginatedModel>((ref) async {
  final useCase = getIt<FetchPaymentsUseCase>();
  final result = await useCase.call();
  return result.fold(
    (failure) => throw failure,
    (data) => data,
  );
});

