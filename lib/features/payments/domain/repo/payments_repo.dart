import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/payment_model.dart';

abstract class PaymentsRepo {
  Future<Either<Failure, PaymentPaginatedModel>> getMyPayments();
}

