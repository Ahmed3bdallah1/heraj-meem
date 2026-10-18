import 'package:heraj_meem/config/api_path.dart';
import 'package:heraj_meem/core/service/webservice/dio_helper.dart';
import 'package:heraj_meem/features/location/data/models/city_model.dart';
import 'package:heraj_meem/features/location/data/models/district_model.dart';

abstract class LocationDataSource {
  Future<CitiesResponse> getCities();
  Future<DistrictsResponse> getDistricts(String cityCode);
  Future<NeighborhoodsResponse> getNeighborhoods(
      String cityCode, String districtName);
}

class LocationDataSourceImpl implements LocationDataSource {
  final ApiService apiService;

  LocationDataSourceImpl({required this.apiService});

  @override
  Future<CitiesResponse> getCities() async {
    final res = await apiService.get(url: ApiPath.getCities,returnDataOnly: true);
    return CitiesResponse.fromJson(res);
  }

  @override
  Future<DistrictsResponse> getDistricts(String cityCode) async {
    final res = await apiService.get(
      url: ApiPath.getDistricts(cityCode),
      returnDataOnly: true,
    );
    return DistrictsResponse.fromJson(res);
  }

  @override
  Future<NeighborhoodsResponse> getNeighborhoods(
    String cityCode,
    String districtName,
  ) async {
    final res = await apiService.get(
      url: ApiPath.getNeighborhoods(cityCode, districtName),
      returnDataOnly: true,
    );
    return NeighborhoodsResponse.fromJson(res);
  }
}

