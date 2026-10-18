import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../data_source/payments_data_source.dart';
import '../models/payment_model.dart';
import '../../domain/repo/payments_repo.dart';

class PaymentsRepoImp implements PaymentsRepo {
  final PaymentsDataSource paymentsDataSource;

  PaymentsRepoImp({required this.paymentsDataSource});

  @override
  Future<Either<Failure, PaymentPaginatedModel>> getMyPayments() async {
    try {
      final result = await paymentsDataSource.getMyPayments();
      return Right(result);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure(e.toString()));
    }
  }
}

