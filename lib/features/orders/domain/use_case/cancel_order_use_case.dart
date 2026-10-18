import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../repo/orders_repo.dart';

class CancelOrderUseCase extends UseCaseParam<Map<String, dynamic>, String> {
  final OrdersRepo ordersRepo;

  CancelOrderUseCase({required this.ordersRepo});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String orderId) async {
    final res = await ordersRepo.cancelOrder(orderId);
    return res;
  }
}

