import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../core/use_cases/use_case.dart';
import '../../../../../models/user_model.dart';
import '../repositories/auth_repo.dart';

class LoginUserUseCase
    extends UseCaseParam<UserAuthResponseModel, Map<String, dynamic>> {
  final AuthRepo authRepo;

  LoginUserUseCase(this.authRepo);

  @override
  Future<Either<Failure, UserAuthResponseModel>> call(
      Map<String, dynamic> param) {
    return authRepo.login(param);
  }
}

class LogOutUserUseCase extends UseCaseNoParam<bool> {
  final AuthRepo authRepo;

  LogOutUserUseCase(this.authRepo);

  @override
  Future<Either<Failure, bool>> call([void param]) {
    return authRepo.logOut();
  }
}

class DeleteAccountUseCase extends UseCaseNoParam<bool> {
  final AuthRepo authRepo;

  DeleteAccountUseCase(this.authRepo);

  @override
  Future<Either<Failure, bool>> call([void param]) {
    return authRepo.deleteAccount();
  }
}

class PreLoginUserUseCase
    extends UseCaseParam<PreLoginResponseModel, Map<String, dynamic>> {
  final AuthRepo authRepo;

  PreLoginUserUseCase(this.authRepo);

  @override
  Future<Either<Failure, PreLoginResponseModel>> call(
      Map<String, dynamic> param) {
    return authRepo.preLogin(param);
  }
}


class SocialLoginUserUseCase extends UseCaseParam<UserAuthResponseModel, String> {
  final AuthRepo authRepo;

  SocialLoginUserUseCase(this.authRepo);

  @override
  Future<Either<Failure, UserAuthResponseModel>> call(String param) {
    return authRepo.socialLogin(param);
  }
}
