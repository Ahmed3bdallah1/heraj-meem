import 'package:fpdart/fpdart.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../../models/user_model.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserAuthResponseModel>> login(
      Map<String, dynamic> data);
  Future<Either<Failure, UserAuthResponseModel>> socialLogin(String idToken);

  Future<Either<Failure, bool>> logOut();

  Future<Either<Failure, bool>> deleteAccount();

  Future<Either<Failure, UserAuthResponseModel>> register(
      Map<String, dynamic> data);

  Future<Either<Failure, UserAuthResponseModel>> vendorRegister(
      Map<String, dynamic> data);

  Future<Either<Failure, UserAuthResponseModel>> selectRole(String role);

  Future<Either<Failure, PreLoginResponseModel>> preLogin(
      Map<String, dynamic> data);

  Future<Either<Failure, UserModel>> getMyProfile();
}
