import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../model/address_model.dart';
import '../model/geocoding_model.dart';

abstract class AddressDataSource {
  Future<bool> addAddress({required Map<String, dynamic> map});

  Future<bool> updateAddress(
      {required String addressId, required Map<String, dynamic> map});

  Future<bool> deleteAddress({required String addressId});

  Future<List<AddressModel>> getAddresses();

  Future<GeocodingModel> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}

class AddressDataSourceImp extends AddressDataSource {
  final ApiService apiService;

  AddressDataSourceImp({required this.apiService});

  @override
  Future<bool> addAddress({required Map<String, dynamic> map}) async {
    final requestBody = <String, dynamic>{
      'label': map['label'] ?? '',
      'fullName': map['fullName'] ?? map['name'] ?? '',
      'phone': map['phone'] ?? '',
      'addressLine1': map['addressLine1'] ?? map['address'] ?? '',
      if (map['addressLine2'] != null) 'addressLine2': map['addressLine2'],
      if (map['city'] != null) 'city': map['city'],
      if (map['state'] != null) 'state': map['state'],
      if (map['postalCode'] != null || map['postal_code'] != null)
        'postalCode': map['postalCode'] ?? map['postal_code'],
      if (map['country'] != null) 'country': map['country'],
      if (map['coordinates'] != null) 'coordinates': map['coordinates'],
      if (map['isDefault'] != null) 'isDefault': map['isDefault'],
    };

    await apiService.post(
        url: ApiPath.addAddress,
        requestBody: requestBody,
        returnDataOnly: true);
    return true;
  }

  @override
  Future<bool> updateAddress(
      {required String addressId, required Map<String, dynamic> map}) async {
    final requestBody = <String, dynamic>{
      if (map['label'] != null) 'label': map['label'],
      if (map['fullName'] != null || map['name'] != null)
        'fullName': map['fullName'] ?? map['name'],
      if (map['phone'] != null) 'phone': map['phone'],
      if (map['addressLine1'] != null || map['address'] != null)
        'addressLine1': map['addressLine1'] ?? map['address'],
      if (map['addressLine2'] != null) 'addressLine2': map['addressLine2'],
      if (map['city'] != null) 'city': map['city'],
      if (map['state'] != null) 'state': map['state'],
      if (map['postalCode'] != null || map['postal_code'] != null)
        'postalCode': map['postalCode'] ?? map['postal_code'],
      if (map['country'] != null) 'country': map['country'],
      if (map['coordinates'] != null) 'coordinates': map['coordinates'],
      if (map['isDefault'] != null) 'isDefault': map['isDefault'],
    };

    await apiService.put(
        url: "${ApiPath.updateAddress}/$addressId",
        requestBody: requestBody,
        returnDataOnly: true);
    return true;
  }

  @override
  Future<bool> deleteAddress({required String addressId}) async {
    await apiService.delete(url: "${ApiPath.deleteAddress}/$addressId");
    return true;
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    final res = await apiService.get<Map<String, dynamic>>(
        url: ApiPath.getAddresses, returnDataOnly: true);

    final addressesList = res['addresses'] as List<dynamic>? ?? [];
    return addressesList
        .map(
            (element) => AddressModel.fromJson(element as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GeocodingModel> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final res = await apiService.get<Map<String, dynamic>>(
      url: ApiPath.reverseGeocode(latitude, longitude),
      returnDataOnly: false,
    );

    return GeocodingModel.fromJson(res);
  }
}
