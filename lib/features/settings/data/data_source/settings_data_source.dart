import 'package:heraj_meem/config/api_path.dart';
import 'package:heraj_meem/core/service/webservice/dio_helper.dart';

import '../models/settings_model.dart';

abstract class SettingsDataSource {
  Future<SettingsModel> getSettings();
}

class SettingsDataSourceImpl extends SettingsDataSource {
  final ApiService apiService;

  SettingsDataSourceImpl({required this.apiService});

  @override
  Future<SettingsModel> getSettings() async {
    final res = await apiService.get(url: ApiPath.settings);
    return SettingsModel.fromJson(res);
  }
}
