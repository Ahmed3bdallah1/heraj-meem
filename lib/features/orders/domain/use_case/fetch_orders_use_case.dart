import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/models/order_model.dart';
import '../repo/orders_repo.dart';

class FetchOrdersUseCase extends UseCaseNoParam<OrdersPaginatedModel> {
  final OrdersRepo repo;

  FetchOrdersUseCase(this.repo);

  @override
  Future<Either<Failure, OrdersPaginatedModel>> call([void param]) {
    return repo.getOrders();
  }
}


class CheckoutUseCase extends UseCaseParam<Map<String, dynamic>, Map<String, dynamic>> {
  final OrdersRepo repo;

  CheckoutUseCase(this.repo);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call([Map<String, dynamic>? param]) {
    final addressId = param?['addressId'] as String? ?? param?['deliveryAddress'] as String? ?? '';
    final paymentMethod = param?['paymentMethod'] as String? ?? 'card';
    final notes = param?['notes'] as String?;
    final shipping = param?['shipping'] as Map<String, dynamic>?;
    return repo.checkout(
      addressId: addressId,
      paymentMethod: paymentMethod,
      notes: notes,
      shipping: shipping,
    );
  }
}