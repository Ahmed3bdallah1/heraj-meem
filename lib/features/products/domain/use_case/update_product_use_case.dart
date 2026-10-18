import 'package:fpdart/fpdart.dart';
import 'package:tuple/tuple.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/product_repo.dart';

class UpdateProductUseCase extends UseCaseParam<Map<String, dynamic>, Tuple2<String, Map<String, dynamic>>> {
  final ProductRepo productRepo;

  UpdateProductUseCase(this.productRepo);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(Tuple2<String, Map<String, dynamic>> param) {
    return productRepo.updateProduct(param.item1, param.item2);
  }
}

