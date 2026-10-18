import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/payment_model.dart';
import '../repo/payments_repo.dart';

class FetchPaymentsUseCase extends UseCaseNoParam<PaymentPaginatedModel> {
  final PaymentsRepo paymentsRepo;

  FetchPaymentsUseCase(this.paymentsRepo);

  @override
  Future<Either<Failure, PaymentPaginatedModel>> call() {
    return paymentsRepo.getMyPayments();
  }
}

