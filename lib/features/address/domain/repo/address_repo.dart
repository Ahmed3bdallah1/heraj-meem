import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../data/model/address_model.dart';
import '../../data/model/geocoding_model.dart';

abstract class AddressRepo {
  Future<Either<Failure,bool>> addAddress({required Map<String,dynamic> map});

  Future<Either<Failure,bool>> updateAddress({required String addressId, required Map<String,dynamic> map});

  Future<Either<Failure,bool>> deleteAddress({required String addressId});

  Future<Either<Failure,List<AddressModel>>> getAddresses();

  Future<Either<Failure, GeocodingModel>> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}