import 'package:fpdart/fpdart.dart';
import 'package:tuple/tuple.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../data/model/address_model.dart';
import '../../data/model/geocoding_model.dart';
import '../repo/address_repo.dart';

class FetchAddressesUseCase extends UseCaseNoParam<List<AddressModel>> {
  final AddressRepo addressRepo;

  FetchAddressesUseCase(this.addressRepo);

  @override
  Future<Either<Failure, List<AddressModel>>> call() {
    return addressRepo.getAddresses();
  }
}

class AddAddressUseCase extends UseCaseParam<bool, Map<String,dynamic>> {
  final AddressRepo addressRepo;

  AddAddressUseCase(this.addressRepo);

  @override
  Future<Either<Failure, bool>> call([Map<String,dynamic>? param]) {
    return addressRepo.addAddress(map: param!);
  }
}

class UpdateAddressUseCase extends UseCaseParam<bool, Tuple2<String, Map<String,dynamic>>> {
  final AddressRepo addressRepo;

  UpdateAddressUseCase(this.addressRepo);

  @override
  Future<Either<Failure, bool>> call([Tuple2<String, Map<String,dynamic>>? param]) {
    return addressRepo.updateAddress(addressId: param!.item1, map: param.item2);
  }
}

class DeleteAddressUseCase extends UseCaseParam<bool, String> {
  final AddressRepo addressRepo;

  DeleteAddressUseCase(this.addressRepo);

  @override
  Future<Either<Failure, bool>> call([String? param]) {
    return addressRepo.deleteAddress(addressId: param!);
  }
}

class ReverseGeocodeUseCase
    extends UseCaseParam<GeocodingModel, Tuple2<double, double>> {
  final AddressRepo addressRepo;

  ReverseGeocodeUseCase(this.addressRepo);

  @override
  Future<Either<Failure, GeocodingModel>> call(
      [Tuple2<double, double>? param]) {
    return addressRepo.reverseGeocode(
      latitude: param!.item1,
      longitude: param.item2,
    );
  }
}