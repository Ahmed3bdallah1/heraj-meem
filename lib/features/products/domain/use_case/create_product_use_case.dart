import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../repo/product_repo.dart';

class CreateProductUseCase extends UseCaseParam<Map<String, dynamic>, Map<String, dynamic>> {
  final ProductRepo productRepo;

  CreateProductUseCase(this.productRepo);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(Map<String, dynamic> param) {
    return productRepo.createProduct(param);
  }
}

